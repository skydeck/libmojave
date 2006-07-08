(*
 * Extra unix utilities.
 *
 * ----------------------------------------------------------------
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/htmlman/default.html or visit http://metaprl.org/
 * for more information.
 *
 * Copyright (C) 1998-2005 Jason Hickey, Cornell University
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * Author: Jason Hickey
 * jyh@cs.cornell.edu
 *)

(*
 * Print the location of the stack pointer for debugging.
 *)
val print_stack_pointer : unit -> unit

(*
 * Location of the home directory.
 *)
val home_dir : string

(*
 * Location of application data (this is the same as home_dir
 * except on Win32).
 *)
val application_dir : string

(*
 * Really read some number of bytes.
 *)
val really_read : Unix.file_descr -> string -> int -> int -> unit

(*
 * Copy an entire file.
 *)
val copy_file : string -> string -> int -> unit

(*
 * Make all the directories in a path.
 *)
val mkdirhier : string -> unit

(*
 * Home directory of the current user.
 *)
val home_dir : string

(*
 * C interface.
 *)
val int_of_fd : Unix.file_descr -> int

(*
 * Lock utilities.
 *)
val lockf : Unix.file_descr -> Unix.lock_command -> int -> unit

(*
 * File truncation.
 *)
val ftruncate : Unix.file_descr -> unit

(*
 * Get a value from the registry.
 * raises Not_found if the entry is not found or you are not using Win32.
 *)
type registry_hkey =
    HKEY_CLASSES_ROOT
  | HKEY_CURRENT_CONFIG
  | HKEY_CURRENT_USER
  | HKEY_LOCAL_MACHINE
  | HKEY_USERS

val registry_find  : registry_hkey -> string -> string -> string

(*
 * Open a file.
 * This is mainly for debugging.
 *)
val openfile : string -> Unix.open_flag list -> Unix.file_perm -> Unix.file_descr

(*
 * Simple file locking.
 *)
type flock_command =
   LOCK_UN
 | LOCK_SH
 | LOCK_EX
 | LOCK_TSH
 | LOCK_TEX

val flock : Unix.file_descr -> flock_command -> unit

(*
 * -*-
 * Local Variables:
 * Caml-master: "refiner"
 * End:
 * -*-
 *)
