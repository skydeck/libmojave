(* CAUTION: this is a generated file.  If you edit it, all changes will be lost! *)
# 1 "lm_pervasives.mlp"
# 1 "<built-in>"
# 1 "<command line>"


# 1 "lm_pervasives.h" 1
# 4 "<command line>" 2
# 1 "lm_pervasives.mlp"
(*
 * Override some basic functions, mostly for debugging.
 *
 * ----------------------------------------------------------------
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
 *
 * Copyright (C) 1998 Jason Hickey, Cornell University
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * Author: Jason Hickey
 * jyh@cs.cornell.edu
 *)
open Lm_format

(*
 * Override input functions for debugging.
 *)
let open_in = Pervasives.open_in
let open_in_bin = Pervasives.open_in_bin

(*
 * For now, just use normal output channels.
 *)
type out_channel = formatter

(*
 * Standard channels.
 *)
let stdout = std_formatter
let stderr = err_formatter
let stdstr = str_formatter

(*
 * Get the string from the string formatter.
 *)
let flush_stdstr = flush_str_formatter

(*
 * Open new output channels.
 *)
let open_out name =
   formatter_of_out_channel (open_out name)

let open_out_bin name =
   formatter_of_out_channel (open_out_bin name)
# 79 "lm_pervasives.mlp"
(*
 * Lm_format supports rbuffer printing and diversion.
 *)
let capability_divert = true


(*
 * Output.
 *)
let output_char = pp_print_char
let output_string = pp_print_string
let output_rbuffer = pp_print_rbuffer

(*
 * Normal printing.
 *)
let print_char = pp_print_char std_formatter
let print_int = pp_print_int std_formatter
let print_string = pp_print_string std_formatter
let print_rbuffer = pp_print_rbuffer std_formatter

let prerr_char = pp_print_char err_formatter
let prerr_int = pp_print_int err_formatter
let prerr_string = pp_print_string err_formatter
let prerr_rbuffer = pp_print_rbuffer err_formatter

(*
 * Print a newline and flush.
 *)
let flush buf = pp_print_flush buf ()
let eflush buf = pp_print_newline buf ()

(*
 * Printing functions.
 *)
module PervasivesPrintf =
struct
   let printf = printf
   let eprintf = eprintf
   let sprintf = sprintf
   let fprintf = fprintf
end

(*
 * List separated by semicolons.
 *)
let rec print_any_list print out l =
   match l with
      [h] ->
         print out h
    | h::t ->
         print out h;
         output_string out "; ";
         print_any_list print out t
    | [] ->
         ()

let print_string_list =
   print_any_list pp_print_string

let print_int_list =
   print_any_list pp_print_int

(*
 * -*-
 * Local Variables:
 * Caml-master: "refiner"
 * End:
 * -*-
 *)
