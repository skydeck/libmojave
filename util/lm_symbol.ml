(*
 * Right now the symbol table is just a representation of strings.
 *
 * ----------------------------------------------------------------
 *
 * Copyright (C) 1999-2002 Jason Hickey, Caltech
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
 * jyh@cs.caltech.edu
 *
 * ----------------------------------------------------------------
 * Revision History
 *
 *  2002  Dec  4  Michael Maire  Added SymbolIndex
 *                               Added sets, tables, indices for
 *                               symbol pairs and triples
 *)
open Lm_format
open Lm_debug

let debug_symbol = ref false

(*
 * We no longer use a hashtable.
 * Symbols with a 0 index are interned.
 *)
type symbol = int * string
type var = symbol

(* An "empty" variable name *)
let empty_var = (0,"")

let new_number =
   let count = ref 100 in
      (fun () ->
            let i = !count in
               count := succ i;
               i)

(*
 * Get the integer prefix.
 *)
let to_int (i, _) =
   i

(*
 * Get the string suffix.
 *)
let to_string (_, s) =
   s

(*
 * Mangle a string so it uses printable characters.
 *)
let is_special s =
   let len = String.length s in
   let rec search i =
      if i = len then
         false
      else
         match s.[i] with
            'a'..'z'
          | 'A'..'Z'
          | '0'..'9'
          | '_'
          | '.'
          | '%' ->
               search (succ i)
          | _ ->
               true
   in
      search 0

let rec buffer_mangle buf s i len =
   if len <> 0 then
      let c = s.[i] in
      let _ =
         match c with
            'a'..'z'
          | 'A'..'Z'
          | '0'..'9'
          | '_' ->
               Buffer.add_char buf c
          | _ ->
               Buffer.add_char buf '.';
               Buffer.add_string buf (string_of_int (Char.code c))
      in
         buffer_mangle buf s (succ i) (pred len)

let mangle s =
   let len = String.length s in
   let buf = Buffer.create len in
      buffer_mangle buf s 0 len;
      Buffer.contents buf


(*
 * Add a symbol to the table.
 *)
let stop s =
   eprintf "Bogus symbol %s@." s;
   false

let char0 = Char.code '0'

let rec zeros s i =
   (i < 0) ||
   match s.[i] with
      '1'..'9' -> false
    | '0' -> zeros s (pred i)
    | _ -> true
let rec pad_with_underscore s i =
   if i <= 0 then true else
   let i = pred i in
   match s.[i] with
      '_' -> pad_with_underscore s i
    | '0' -> not (zeros s (pred i))
    | '1' .. '9' -> true
    | _ -> false

let add =
   let rec loop s fact n i =
      if i < 0 then
         0, s
      else
         match s.[i] with
            '_' ->
               n, String.sub s 0 (if pad_with_underscore s i then i else i + 1)
          | '0' when zeros s (i - 1) ->
               n, String.sub s 0 (succ i)
          | '0'..'9' as c ->
               loop s (fact * 10) (n + fact * (Char.code c - char0)) (pred i)
          | _ ->
               n, String.sub s 0 (succ i)
   in
      fun s -> loop s 1 0 (String.length s - 1)

let make s i = (i, s)

let add_mangle s =
   add (mangle s)

let reintern (_, s) =
   add s

(*
 * Create a new symbol.
 * Don't add it to the table.
 *)
let new_symbol_string s =
   new_number (), s

let new_symbol (_, v) =
   new_symbol_string v

let new_symbol_pre pre (_, v) =
   let s =
      if debug debug_symbol then
         v ^ "/" ^ pre
      else
         v
   in
      new_symbol_string s

(*
 * Create a new symbol, avoiding the ones defined by the predicate.
 *)
let new_name (_, v) pred =
   let rec search i =
      let nv = i, v in
         if pred nv then
            search (succ i)
         else
            nv
   in
      search 0

(*
 * Create a new symbol, calling the function f until it
 * returns non-nil.
 *)
let new_name_gen (_, v) f =
   let rec search i =
      let nv = i, v in
         match f nv with
            Some x ->
               x
          | None ->
               search (succ i)
   in
      search 0

(*
 * Check if the symbol is in the table.
 *)
let is_interned (i, _) =
   i = 0

(*
 * Printer.
 * If the symbol is not a defined symbol,
 * print the index.
 *)
let string_of_symbol (i,s) =
   let len = String.length s in
   let s = if pad_with_underscore s len then s ^ "_" else s in
      if i = 0 then
         s
      else
         s ^ string_of_int i

let pp_print_symbol buf v =
   Lm_format.pp_print_string buf (string_of_symbol v)

let rec pp_print_symbol_list buf vl =
   match vl with
      [v] ->
         pp_print_symbol buf v
    | v :: vl ->
         fprintf buf "%a, %a" pp_print_symbol v pp_print_symbol_list vl
    | [] ->
         ()

let print_symbol out v =
   Lm_printf.output_string out (string_of_symbol v)

let rec print_symbol_list out vl =
   match vl with
      [v] ->
         print_symbol out v
    | v :: vl ->
         Lm_printf.fprintf out "%a, %a" print_symbol v print_symbol_list vl
    | [] ->
         ()

(*
 * Print extended symbols. Used in FIR printing.
 *)
exception Has

let string_of_ext_symbol (i, s) =
   let has_special_char s =
      try
         for i = 0 to String.length s - 1 do
            let c = Char.lowercase (String.get s i) in
               if not ((Char.code c >= Char.code 'a' && Char.code c <= Char.code 'z')
                       || (Char.code c >= Char.code '0' && Char.code c <= Char.code '9')
                       || c = '_')
               then
                  raise Has
         done;
         false
      with
         Has ->
            true
   in
   let s =
      if i = 0 then
         s
      else
         sprintf "%s%d" s i
   in
      if has_special_char s then
         sprintf "`\"%s\"" s
      else
         s

let pp_print_ext_symbol buf v =
   Lm_format.pp_print_string buf (string_of_ext_symbol v)

(*
 * Compare for equality.
 *)
let eq (s1 : symbol) (s2 : symbol) =
   s1 = s2

let compare (i1, s1) (i2, s2) =
   match i1 - i2 with
      0 -> Pervasives.compare s1 s2
    | i -> i

(*
 * Compare pair of symbols for equality.
 *)
let compare_pair (s1, s2) (s1', s2') =
   let res = compare s1 s1' in
   if res = 0 then
      compare s2 s2'
   else
      res

(*
 * Compare triple of symbols for equality.
 *)
let compare_triple (s1, s2, s3) (s1', s2', s3') =
   let res = compare_pair (s1, s2) (s1, s2') in
   if res = 0 then
      compare s3 s3'
   else
      res

(*
 * Build sets, tables, indices where the keys are symbols,
 * ordered symbol pairs, or orderd symbol triples.
 *)
module Base =
struct
   type t = symbol
   let compare = compare
end

module PairBase =
struct
   type t = symbol * symbol
   let compare = compare_pair
end

module TripleBase =
struct
   type t = symbol * symbol * symbol
   let compare = compare_triple
end

module SymbolSet = Lm_set.LmMake (Base)
module SymbolTable = Lm_map.LmMake (Base)
module SymbolMTable = Lm_map.LmMakeList (Base)
module SymbolIndex = Lm_index.LmMake (Base)

module SymbolPairSet = Lm_set.LmMake (PairBase)
module SymbolPairTable = Lm_map.LmMake (PairBase)
module SymbolPairMTable = Lm_map.LmMakeList (PairBase)
module SymbolPairIndex = Lm_index.LmMake (PairBase)

module SymbolTripleSet = Lm_set.LmMake (TripleBase)
module SymbolTripleTable = Lm_map.LmMake (TripleBase)
module SymbolTripleMTable = Lm_map.LmMakeList (TripleBase)
module SymbolTripleIndex = Lm_index.LmMake (TripleBase)

(*
 * Symbol lists are also useful.
 *)
module SymbolListCompare =
struct
   type t = symbol list

   let rec compare l1 l2 =
      match l1, l2 with
         v1 :: l1, v2 :: l2 ->
            let cmp = Base.compare v1 v2 in
               if cmp = 0 then
                  compare l1 l2
               else
                  cmp
       | [], _ :: _ ->
            -1
       | _ :: _, [] ->
            1
       | [], [] ->
            0
end

module SymbolListSet = Lm_set.LmMake (SymbolListCompare)
module SymbolListTable = Lm_map.LmMake (SymbolListCompare)

let print_symbol_set out s =
   print_symbol_list out (SymbolSet.to_list s)

(*
 * -*-
 * Local Variables:
 * Caml-master: "set"
 * End:
 * -*-
 *)
