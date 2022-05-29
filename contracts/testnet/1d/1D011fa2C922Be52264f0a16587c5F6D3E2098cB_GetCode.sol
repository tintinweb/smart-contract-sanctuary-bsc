/***
 *                     .,cldxxxxdol:;,.
 *                  ..:d0NWWWWWNNNNX0Oxo:.
 *               ...;xXNNXOdlcc:clodxKX0Odlc:,.
 *              ..':kXXKx;.      ..;:o0NWNX0xdc.
 *             ...;dKKOl.          ..,:lddkKOdc.
 *             ..,:xXOd;              ..,:xXOd;
 *             ..;:xKkd;              ..;lOKko.
 *              .;:o0Odl.            ..,:xX0x:
 *              .'::x0kdc.           ..;lOKko'
 *              ..,cxXOdc.           .':lOKkdc.
 *              ..;ckX0xo:.         ..'lOKX0d:.
 *               .':cdO0kdl'       ..,l0NX0o'
 *                 .,:cd0kdo,     ..,o0XKk:
 *                  .':cd0Odo;. ...;dKXKx,
 *                    .;:oOOxxo:'.:kXX0o'
 *                     .;:lO0kkxl;l0XOo'
 *                     ..;ckKOkxo:l00xl.
 *                     .'coOKOkxo:l00dl'
 *                 .':lokKXXKOdlc:lOX0Oxoc;,'..
 *            ..;lx0XNWWWNKOo;...,:lk0XXNXK0Oxoc;..
 *         ..:d0NWWNX0xoc:,.      ...,;ldxkOKKK0kdl;.
 *      ...;xXNNXOo:'.                  ...,:ldk00kxo:.
 *     ..'ckXXKx;.                           .,;cdOOxdc.
 *    ..':dKKOl.                               .,:ck0xd:
 *    ..;cOXOo'                                 .,:lOOdl.
 *   ..';o00xc.                                 .'::x0xd;
 *   ..,:dKOd:                                  ..;:dKkd:.
 *   ..,:xKkd;                                   .,:o0Odc.
 *   ..;:kXOxc'''''''''''''''''''''''''''''''''',;ldkKOdc.
 *   ..;cOWNXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXNWNXOdc.
 *    .,:d0KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK0OOdc,
 *     ................................................
 *
 * ██╗    ██████╗ ██╗██████╗     ████████╗██╗  ██╗██╗███████╗
 * ██║    ██╔══██╗██║██╔══██╗    ╚══██╔══╝██║  ██║██║██╔════╝
 * ██║    ██║  ██║██║██║  ██║       ██║   ███████║██║███████╗
 * ██║    ██║  ██║██║██║  ██║       ██║   ██╔══██║██║╚════██║
 * ██║    ██████╔╝██║██████╔╝       ██║   ██║  ██║██║███████║
 * ╚═╝    ╚═════╝ ╚═╝╚═════╝        ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝
 *
 * @author: @MaxFlowO2 on Twitter/GitHub
 * @purpose: I dunno yeet some stuff and play in solidity
 * 
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract GetCode {

  function thisCode() external view returns (bytes memory o_code) {
    return address(this).code;
  }

  function thisAssembly() external view returns (bytes memory o_code) {
    address _addr = address(this);
    assembly {
      // retrieve the size of the code
      let size := extcodesize(_addr)
      // allocate output byte array
      // by using o_code = new bytes(size)
      o_code := mload(0x40)
      // new "memory end" including padding
      mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
      // store length in memory
      mstore(o_code, size)
      // actually retrieve the code, this needs assembly
      extcodecopy(_addr, add(o_code, 0x20), 0, size)
    }
  }

  /// Dev: Can not run on self... only others.

//  function thisRunTime() external view returns (bytes memory) {
//    return type(GetCode).runtimeCode;
//  }

//  function thisCreation() external view returns (bytes memory) {
//    return type(GetCode).creationCode;
//  }

  function atCode(address _addr) external view returns (bytes memory o_code) {
    return _addr.code;
  }

  function atAssembly(address _addr) external view returns (bytes memory o_code) {
    assembly {
      // retrieve the size of the code
      let size := extcodesize(_addr)
      // allocate output byte array
      // by using o_code = new bytes(size)
      o_code := mload(0x40)
      // new "memory end" including padding
      mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
      // store length in memory
      mstore(o_code, size)
      // actually retrieve the code, this needs assembly
      extcodecopy(_addr, add(o_code, 0x20), 0, size)
    }
  }
}