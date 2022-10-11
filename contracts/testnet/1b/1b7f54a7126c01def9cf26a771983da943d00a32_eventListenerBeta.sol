/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: eventListener
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: demo for MaaS
 */

// SPDX-License-Identifier: Apache 2.0
pragma solidity >=0.8.0 <0.9.0;

// import max access
// import interfaces (if need be, and will have a need be later)

contract eventListenerBeta {
  // globals
  uint public chainID = block.chainid;

  event Send(bytes payload, uint toChain, address user);
  event Receive(bytes payload, address user);

  function send(
    bytes memory payload
  , uint chain
  , address user
  ) public {
  emit Send(payload,chain,user);
  }

  function send(
    bytes memory payload
  , uint chain
  ) public {
  emit Send(payload,chain,msg.sender);
  }

  function pReceive(
    bytes memory payload
  , address user
  ) public {
  emit Receive(payload,msg.sender);
  }

}