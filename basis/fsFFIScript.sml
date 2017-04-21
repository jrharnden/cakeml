open preamble mlstringTheory cfHeapsBaseTheory

val _ = new_theory"fsFFI"

(* TODO: put these calls in a re-usable option syntax Lib *)
val _ = monadsyntax.temp_add_monadsyntax();
val _ = temp_overload_on ("return", ``SOME``)
val _ = temp_overload_on ("fail", ``NONE``)
val _ = temp_overload_on ("SOME", ``SOME``)
val _ = temp_overload_on ("NONE", ``NONE``)
val _ = temp_overload_on ("monad_bind", ``OPTION_BIND``)
val _ = temp_overload_on ("monad_unitbind", ``OPTION_IGNORE_BIND``)
(* -- *)
(*
val _ = type_abbrev("fs", ``: mlstring -> (char list) option``); *)
(* rmk: what if we use sys_chdir later? filenames are not absolute *)

(* Issues with the current model:
* no absolute paths (?)
* write 
* read and write shouldn't be byte by byte.
*  -> closer to syscall spec
*)

(* files: a list of file names and their content.
*   Absolute or relative file name ?
*  infds: descriptor * (filename * position)
*)
val _ = Datatype`
  RO_fs = <| files : (mlstring # char list) list ;
             infds : (num # (mlstring # num)) list |>
`

val RO_fs_component_equality = theorem"RO_fs_component_equality";

(* well formed file descriptor: all descriptors are < 255 
*  and correspond to file names in files *)
val wfFS_def = Define`
  wfFS fs =
    ∀fd. fd ∈ FDOM (alist_to_fmap fs.infds) ⇒
         fd < 255 ∧
         ∃fnm off. ALOOKUP fs.infds fd = SOME (fnm,off) ∧
                   fnm ∈ FDOM (alist_to_fmap fs.files)
`;

(* find smallest unused descriptor index *)
val nextFD_def = Define`
  nextFD fsys = LEAST n. ~ MEM n (MAP FST fsys.infds)
`;

(* adds a new file in infds *)
val openFile_def = Define`
  openFile fnm fsys =
     let fd = nextFD fsys
     in
       do
          assert (fd < 255) ;
          ALOOKUP fsys.files fnm ;
          return (fd, fsys with infds := (nextFD fsys, (fnm, 0)) :: fsys.infds)
       od
`;
(* TODO need another open with offset at the end of the file *)

(* update filesystem with newly opened file *)
val openFileFS_def = Define`
  openFileFS fnm fs =
    case openFile fnm fs of
      NONE => fs
    | SOME (_, fs') => fs'
`;

(* end of file is reached when the position index is the length of the file *)
val eof_def = Define`
  eof fd fsys =
    do
      (fnm,pos) <- ALOOKUP fsys.infds fd ;
      contents <- ALOOKUP fsys.files fnm ;
      return (LENGTH contents <= pos)
    od
`;

(* checks if a descriptor index is in the file descriptor *)
val validFD_def = Define`
  validFD fd fs ⇔ fd ∈ FDOM (alist_to_fmap fs.infds)
`;

(* reads (at most) n chars *)
val FDchars_def = Define`
  FDchars fd fs n =
    do
      (fnm, off) <- ALOOKUP fs.infds fd ;
      content <- ALOOKUP fs.files fnm ;
      return(TAKE (MIN (LENGTH content - off) n) content)
    od
`;
(* TODO: not accurate.
* it can be less for various other reasons 
* "fewer bytes are actually available right now (maybe because we were
* close to end-of-file, or because we are reading from a pipe, or from a
* terminal), or because the system call was interrupted by a signal." *)

(* increase by n the position in file descriptor *)
val bumpFD_def = Define`
  bumpFD fd fs n =
  case FDchars fd fs n of
       NONE => fs
     | SOME l => fs with infds updated_by (ALIST_FUPDKEY fd (I ## ((+) n)))
`;

(* reads several chars and update position *)
(* TODO: non-deterministic number of read chars? *)
val read_def = Define`
  read fd n fsys =
    if validFD fd fsys then 
      SOME (FDchars fd fsys n, bumpFD fd fsys n)
    else NONE
`;

(* writes several chars at the end of the file *)
val write_def = Define`
  write fd n chars fsys =
  do
    (fnm, off) <- ALOOKUP fsys.infds fd ;
    content <- ALOOKUP fsys.files fnm ;
    return(MIN n (LENGTH chars),
           fsys with files := (fnm, content ++ TAKE n chars) :: (A_DELKEY fnm fsys.files))
    od
`;

(* remove file from file descriptor *)
val closeFD_def = Define`
  closeFD fd fsys =
    do
       ALOOKUP fsys.infds fd ;
       return ((), fsys with infds := A_DELKEY fd fsys.infds)
    od
`;

(* encoding functions. check use *)
val encode_files_def = Define`
  encode_files fs = encode_list (encode_pair (Str o explode) Str) fs
`;

val encode_fds_def = Define`
  encode_fds fds =
     encode_list (encode_pair Num (encode_pair (Str o explode) Num)) fds
`;

val encode_def = zDefine`
  encode fs = cfHeapsBase$Cons
                         (encode_files fs.files)
                         (encode_fds fs.infds)
`


val decode_files_def = Define`
  decode_files f = decode_list (decode_pair (lift implode o destStr) destStr) f
`
val decode_fds_def = Define`
  decode_fds =
    decode_list (decode_pair destNum
                             (decode_pair (lift implode o destStr) destNum))
`;

val decode_def = zDefine`
  (decode (Cons files0 fds0) =
     do
        files <- decode_files files0 ;
        fds <- decode_fds fds0 ;
        return <| files := files ; infds := fds |>
     od) ∧
  (decode _ = fail)
`;

(* ----------------------------------------------------------------------
    Making the above available as FFI functions
   ----------------------------------------------------------------------

    There are four operations to be used in the example:

    1. write char to stdout
    2. open file
    3. read char from file descriptor
    4. close file

   ---------------------------------------------------------------------- *)
(* truncate byte list after null byte and convert into char list *)
val getNullTermStr_def = Define`
  getNullTermStr (bytes : word8 list) =
     let sz = findi 0w bytes
     in
       if sz = LENGTH bytes then NONE
       else SOME(MAP (CHR o w2n) (TAKE sz bytes))
`

(* read file name from the first non null bytes
*  open the file 
*  write its file descriptor index in the first byte *)
val ffi_open_def = Define`
  ffi_open bytes fs =
    do
      fname <- getNullTermStr bytes;
      (fd, fs') <- openFile (implode fname) fs;
      assert(fd < 255);
      return (LUPDATE (n2w fd) 0 bytes, fs')
    od ++
    return (LUPDATE 255w 0 bytes, fs)`;
(* TODO: open truncate or append *)

(* 
* [descriptor index; number of char to read; buffer]
*   -> [return code; number of read chars; read chars]
* corresponding system call:
*  ssize_t read(int fd, void *buf, size_t count) *)
val ffi_read_def = Define`
  ffi_read bytes fs =
    do
    (* the buffer contains at least the number of requested bytes *)
      assert(LENGTH bytes >= w2n (HD (TL bytes)) + 2);
      (lo, fs') <- read (w2n (HD bytes)) (w2n (HD (TL bytes))) fs;
      (case lo of
      (* return error code *)
      | NONE => return ([1w], fs')
      (* return ok code and list of chars
      *  the end of the array may remain unchanged *)
      | SOME l => return (0w :: n2w (LENGTH l) ::
                          MAP (n2w o ORD) l ++
                          DROP (LENGTH l +2) bytes, fs'))
      od`;
(* TODO: type error? *)

(* [descriptor index; number of chars to write; chars to write]
*    -> [return code; number of written chars]
* corresponding system call:
* ssize_t write(int fildes, const void *buf, size_t nbytes) *)
val ffi_write_def = Define`
  ffi_write bytes fs =
    do
    (* the buffer contains at least the number of requested bytes *)
      assert(LENGTH bytes >= 2);
      (* number of bytes written, and updated fs *)
      (nw, fs') <- write (w2n (HD bytes)) 
                         (w2n (HD (TL bytes))) 
                         (MAP (CHR o w2n) (TL (TL bytes))) 
                         fs;
      (* return ok code and list of chars *)
      return ([0w,n2w nw], fs')
    od ++ return ([1w], fs')`;
(* TODO: error *)

(* closes a file given its descriptor index *)
val ffi_close_def = Define`
  ffi_close bytes fs =
    do
      assert(LENGTH bytes = 1);
      do
        (_, fs') <- closeFD (w2n (HD bytes)) fs;
        return (LUPDATE 1w 0 bytes, fs')
      od ++
      return (LUPDATE 0w 0 bytes, fs)
    od`;

(* given a file descriptor, returns 0, 1 if EOF is met. 255 is an error *)
val ffi_isEof_def = Define`
  ffi_isEof bytes fs =
    do
      assert(LENGTH bytes = 1);
      do
        b <- eof (w2n (HD bytes)) fs ;
        return (LUPDATE (if b then 1w else 0w) 0 bytes, fs)
      od ++
      return (LUPDATE 255w 0 bytes, fs)
    od`;

val rofs_ffi_part_def = Define`
  rofs_ffi_part =
    (encode,decode,
      [("open",ffi_open);
       ("read",ffi_read);
       ("close",ffi_close);
       ("isEof",ffi_isEof)])`;

val _ = export_theory();
