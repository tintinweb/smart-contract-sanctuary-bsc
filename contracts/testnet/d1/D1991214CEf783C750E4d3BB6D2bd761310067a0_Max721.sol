/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Max-721
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Demo of the Ferrari
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity 0.8.17;

import "./Max721Implementation2.sol";
import "./lib/Roles.sol";
import "./lib/721.sol";
import "./lib/PsuedoRand.sol";

contract Max721 is Max721Implementation2 {

  using Roles for Roles.Role;
  using Lib721 for Lib721.Token;
  using PsuedoRand for PsuedoRand.Engine;

  constructor() {
    token721.setName("Max721");
    token721.setSymbol("M721");
    contractRoles.add(ADMIN, msg.sender);
    contractRoles.add(DEVS, msg.sender);
    contractRoles.add(OWNERS, msg.sender);
  }

  function publicMint()
    external {
    token721.mint(msg.sender, nftEngine.mintID());
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Time Cop, interface for a time based mechanism for solidity
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for Time Cop
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface ITimeCop is IERC165 {

  /// @dev this is the struct from lib/TimeCop.sol for epochs
  struct Epoch {
    uint256 start;
    uint256 end;
  }

  /// @dev function (getter) for epoch start and end for epoch
  /// @param epoch: uint256 of what epoch you want to return
  /// @return unix.timestamp for start of epoch (seconds)
  /// @return unix.timestamp for end of epoch (seconds)
  function getTimes(
    uint256 epoch
  ) external
    view
    returns (uint256, uint256);

  /// @dev function (getter) for current epoch
  /// @return uint256 of current epoch's number
  function getEpoch()
    external
    view
    returns (uint256);

  /// @dev function (state storage) will set an epoch and push to Epoch[]
  /// @dev this should be done in order, V2 will have an organizer?
  /// @param start: start time of this epoch in unix.timestamp (seconds)
  /// @param duration: length in seconds of the epoch
  function setEpoch(
    uint256 start
  , uint256 duration
  ) external;

  /// @dev function (state storage) will advance current epoch by 1
  function nextEpoch()
    external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Payment Splitter, interface extension for erc20 payments
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for Payment Splitter, extension for ERC20's
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./ISplitter.sol";

interface ISplitterERC20 is ISplitter {

  /// @dev returns total releases in ERC20
  /// @param _token ERC20 Contract Address
  /// @return uint256 of all ERC20 released in address.decimals()
  function totalReleased(
    address _token
  ) external
    view
    returns (uint256);

  /// @dev returns released ERC20 of an payee
  /// @param _token ERC20 Contract Address
  /// @param payee address of payee to look up
  /// @return mapping(address => uint) of _released
  function released(
    address _token
  , address payee
  ) external
    view
    returns (uint256);

  /// @dev returns amount of ERC20 that can be released to payee
  /// @param _token ERC20 Contract Address
  /// @param payee address of payee to look up
  /// @return uint in address.decimals() of ERC20 to release
  function releasable(
    address _token
  , address payee
  ) external
    view
    returns (uint256);

  /// @dev returns index number of token
  /// @param ca address of erc20 smart contract
  /// @return address at token[index]
  function token(
    address ca
  ) external
    view
    returns (uint256);

  /// @dev this returns the array of tokens[]
  /// @return address[] tokens
  function tokens()
    external
    view
    returns (address[] memory);

  /// @dev this claims all ERC20 on contract for msg.sender
  /// @param _token ERC20 Contract Address
  function claim(
    address _token
  ) external;

  /// @dev This pays all payees
  /// @param _token ERC20 Contract Address
  function payClaims(
    address _token
  ) external;

  /// @dev this claims all "eth" and ERC20's from address[] tokens
  ///       on contract for msg.sender
  function claimAll()
    external;

  /// @dev This pays all "eth" and ERC20's from address[] tokens
  ///       on contract for all on address[] payees
  function payAll()
    external;

  /// @dev This adds a token on PaymentSplitterV3.sol
  /// @param _token ERC20 Contract Address to add
  function addToken(
    address _token
  ) external;

  /// @dev This removes a token on PaymentSplitterV3.sol
  /// @param _token ERC20 Contract Address to remove
  function removeToken(
    address _token
  ) external;

  /// @dev This removes all tokens on PaymentSplitterV3.sol
  function clearTokens()
    external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Payment Splitter, interface for ether payments
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for Payment Splitter
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface ISplitter is IERC165 {

  /// @dev returns total shares
  /// @return uint256 of all shares on contract
  function totalShares()
    external
    view
    returns (uint256);

  /// @dev returns shares of an address
  /// @param payee address of payee to return
  /// @return mapping(address => uint) of _shares
  function shares(
    address payee
  ) external
    view
    returns (uint256);

  /// @dev returns total releases in "eth"
  /// @return uint256 of all "eth" released in wei
  function totalReleased()
    external
    view
    returns (uint256);

  /// @dev returns released "eth" of an payee
  /// @param payee address of payee to look up
  /// @return mapping(address => uint) of _released
  function released(
    address payee
  ) external
    view
    returns (uint256);

  /// @dev returns amount of "eth" that can be released to payee
  /// @param payee address of payee to look up
  /// @return uint in wei of "eth" to release
  function releasable(
    address payee
  ) external
    view
    returns (uint256);

  /// @dev returns index number of payee
  /// @param payee number of index
  /// @return address at _payees[index]
  function payeeIndex(
    address payee
  ) external
    view
    returns (uint256);

  /// @dev this returns the array of payees[]
  /// @return address[] payees
  function payees()
    external
    view
    returns (address[] memory);

  /// @dev this claims all "eth" on contract for msg.sender
  function claim()
    external;

  /// @dev This pays all payees
  function payClaims()
    external;

  /// @dev This adds a payee
  /// @param payee Address of payee
  /// @param _shares Shares to send user
  function addPayee(
    address payee
  , uint256 _shares
  ) external;

  /// @dev This removes a payee
  /// @param payee Address of payee to remove
  /// @dev use payPayees() prior to use if anything is on the contract
  function removePayee(
    address payee
  ) external;

  /// @dev This removes all payees
  /// @dev use payPayees() prior to use if anything is on the contract
  function clearPayees()
    external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] List interface, admin extension
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for modification of avowed or disavowed lists via addresses
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IList.sol";

interface IListAdmin is IList {

  /// @notice adding functions to List
  /// @param newAddresses - array of addresses to add
  function addBatchAddresses(
    address[] memory newAddresses
  ) external;

  /// @notice adding functions to List
  /// @param newAddress - address to add
  function addAddresss(
    address newAddress
  ) external;

  /// @notice removing functions to List
  /// @param newAddresses - array of addresses to remove
  function removeBatchAddresses(
    address[] memory newAddresses
  ) external;

  /// @notice removing functions to List
  /// @param newAddress - address to remove
  function removeAddress(
    address newAddress
  ) external;

  /// @notice enables the List
  function enableList()
    external;

  /// @notice disables the List
  function disableList()
    external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] List interface, for address access control
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for avowed or disavowed lists via addresses
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IList is IERC165 {

  /// @notice will return user status on Access
  /// @return - bool if Access is enabled or not
  /// @param myAddress - any user account address, EOA or contract
  function myListStatus(
    address myAddress
  ) external
    view
    returns (bool);

  /// @notice will return status of Access
  /// @return - bool if Access is enabled or not
  function listStatus()
    external
    view
    returns (bool);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] NFT Minting engine, admin interface
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Given tokenId's from [0...X] find a psuedorandom start Y. Then
 *          Mint from Y -> X, 0 -> Y by using modulo division!
 *          Used in LaidBackLlamas, DaemonDao, American Gothic...
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IPsuedoRand.sol";

interface IPsuedoRandAdmin is IPsuedoRand {

  /// @dev this will set the boolean for minter status
  /// @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external;

  /// @dev this will set the minter fees
  /// @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external;

  /// @dev this will set the Provenance Hashes
  /// @param img Provenance Hash of images in sequence
  /// @param json Provenance Hash of metadata in sequence
  /// @notice This will set the start number as well, make sure to set MaxCap
  ///  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external;

  /// @dev this will set the mint engine
  /// @param mintingCap uint for publicMint() capacity of this chain
  /// @param teamMints uint for maximum teamMints() capacity on this chain
  function setEngine(
    uint mintingCap
  , uint teamMints
  ) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] NFT Minting engine, interface (for UX/UI's)
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Given tokenId's from [0...X] find a psuedorandom start Y. Then
 *          Mint from Y -> X, 0 -> Y by using modulo division!
 *          Used in LaidBackLlamas, DaemonDao, American Gothic...
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IPsuedoRand is IERC165 {

  /// @dev will return Provenance hash of images
  /// @return string memory of the Images Hash (sha256)
  function RevealProvenanceImages()
    external
    view
    returns (string memory);

  /// @dev will return Provenance hash of metadata
  /// @return string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    returns (string memory);

  /// @dev will return starting number for mint
  /// @return uint of the start number
  function RevealStartID()
    external
    view
    returns (uint256);

  /// @notice will return status of Minter
  /// @return - bool of active or not
  function minterStatus()
    external
    view
    returns (bool);

  /// @notice will return minting fees
  /// @return - uint of mint costs in wei
  function minterFees()
    external
    view
    returns (uint256);

  /// @notice will return maximum mint capacity
  /// @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    returns (uint256);

  /// @notice will return maximum mint capacity
  /// @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    returns (uint256);

  /// @notice will return maximum "team minting" capacity
  /// @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    returns (uint256);

  /// @notice will return "team mints" count
  /// @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    returns (uint256);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] OpenSea Contract-level metadata, admin extension
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for your ERC721 or ERC1155 contract that returns a URL for the
 *          storefront-level metadata for your contract
 * @custom:uri https://docs.opensea.io/docs/contract-level-metadata
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IContractURI.sol";

interface IContractURIAdmin is IContractURI {

  /// @dev function (state storage) this sets thisContractURI
  /// @param URI: string to be stored in thisContractURI
  /// @dev This URI should return data of the following format:
  ///
  ///         {
  ///           "name": Project's name,
  ///           "description": Project's Description,
  ///           "image": pfp for project,
  ///           "external_link": web url,
  ///           "seller_fee_basis_points": 100 -> Indicates a 1% seller fee.
  ///           "fee_recipient": checksum address
  ///         }
  function setContractURI(
    string memory URI
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] OpenSea Contract-level metadata
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for your ERC721 or ERC1155 contract that returns a URL for the 
 *          storefront-level metadata for your contract
 * @custom:uri https://docs.opensea.io/docs/contract-level-metadata
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IContractURI is IERC165 {

  /// @dev function (getter) returns ContractURI for OpenSea
  /// @return string private thisContractURI on Max721Storage
  /// @dev see metadata schema on IContractURIAdmin.sol
  function contractURI()
    external
    view
    returns (string memory);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP]: MaxFlow's 173/Dev/Roles Interface
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for MaxAccess
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IMAX173.sol";
import "./IMAXDEV.sol";
import "./IRoles.sol";

interface MaxAccess is IMAX173
                     , IMAXDEV
                     , IRoles {

  ///@dev this just imports all 3 and pushes to Implementation

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP]: Contract Roles Standard
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for MaxAccess version of Roles
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IRoles is IERC165 {

  /// @dev Returns `true` if `account` has been granted `role`.
  /// @param role: Bytes4 of a role
  /// @param account: Address to check
  /// @return bool true/false if account has role
  function hasRole(
    bytes4 role
  , address account
  ) external
    view
    returns (bool);

  /// @dev Returns the admin role that controls a role
  /// @param role: Role to check
  /// @return admin role
  function getRoleAdmin(
    bytes4 role
  ) external
    view 
    returns (bytes4);

  /// @dev Grants `role` to `account`
  /// @param role: Bytes4 of a role
  /// @param account: account to give role to
  function grantRole(
    bytes4 role
  , address account
  ) external;

  /// @dev Revokes `role` from `account`
  /// @param role: Bytes4 of a role
  /// @param account: account to revoke role from
  function revokeRole(
    bytes4 role
  , address account
  ) external;

  /// @dev Renounces `role` from `account`
  /// @param role: Bytes4 of a role
  function renounceRole(
    bytes4 role
  ) external;
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title: [Not an EIP]: Contract Developer Standard
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for onlyDev() role
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IMAXDEV is IERC165 {

  /// @dev Classic "EIP-173" but for onlyDev()
  /// @return Developer of contract
  function developer()
    external
    view
    returns (address);

  /// @dev This renounces your role as onlyDev()
  function renounceDeveloper()
    external;

  /// @dev Classic "EIP-173" but for onlyDev()
  /// @param newDeveloper: addres of new pending Developer role
  function transferDeveloper(
    address newDeveloper
  ) external;

  /// @dev This accepts the push-pull method of onlyDev()
  function acceptDeveloper()
    external;

  /// @dev This declines the push-pull method of onlyDev()
  function declineDeveloper()
    external;

  /// @dev This starts the push-pull method of onlyDev()
  /// @param newDeveloper: addres of new pending developer role
  function pushDeveloper(
    address newDeveloper
  ) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#* 
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=: 
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%* 
 *
 * @title:  EIP-173: Contract Ownership Standard, MaxFlowO2's extension
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Interface for enhancing EIP-173
 * @custom:change-log UUPS Upgradable
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/173/IERC173.sol";

interface IMAX173 is IERC173 {

  /// @dev This is the classic "EIP-173" method of renouncing onlyOwner()  
  function renounceOwnership()
    external;

  /// @dev This accepts the push-pull method of onlyOwner()
  function acceptOwnership()
    external;

  /// @dev This declines the push-pull method of onlyOwner()
  function declineOwnership()
    external;

  /// @dev This starts the push-pull method of onlyOwner()
  /// @param newOwner: addres of new pending owner role
  function pushOwnership(
    address newOwner
  ) external;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Time Cop, a time based mechanism for solidity
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library for time based epochs
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library TimeCop {

  using CountersV2 for CountersV2.Counter;

  struct Epoch {
    uint256 start;
    uint256 end;
  }

  struct Enforce {
    Epoch[] list;
    CountersV2.Counter now;
  }

  event EpochSet(uint256 number, uint256 start, uint256 end);
  event EpochAdvanced(uint256 current);

  function setEpoch(
    Enforce storage enforce
  , uint256 start
  , uint256 end
  ) internal {
    Epoch memory create = Epoch(start, end);
    enforce.list.push(create);
    emit EpochSet(enforce.list.length - 1, start, end);
  }

  function advanceEpoch(
    Enforce storage enforce
  ) internal {
    enforce.now.increment();
    emit EpochAdvanced(enforce.now.current());
  }

  function getTimes(
    Enforce storage enforce
  , uint epoch
  ) internal
    view
    returns (uint256, uint256) {
    return (enforce.list[epoch].start, enforce.list[epoch].end);
  }

  function getCurrentEpoch(
    Enforce storage enforce
  ) internal
    view
    returns (uint256) {
    return enforce.now.current();
  }

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Strings
 * @author: OpenZeppelin
 * @dev Strings Library
 * @custom:source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.7.3/contracts/utils/StringsUpgradeable.sol
 * @custom:change-log Readable, External/Public, Removed code comments, MIT -> Apache-2.0
 * @custom:change-log Added MaxSplaining
 * @custom:error-code Str:1 "hex length insufficient"
 *
 * Include with 'using Strings for <insert type>'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library Strings {

  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  uint8 private constant _ADDRESS_LENGTH = 20;

  error MaxSplaining(string reason);

  function toString(
    uint256 value
  ) internal
    pure
    returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function toHexString(
    uint256 value
  ) internal
    pure
    returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  function toHexString(
    uint256 value
  , uint256 length
  ) internal
    pure
    returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    if (value != 0) {
      revert MaxSplaining({
        reason: "Str:1"
      });
    }
    return string(buffer);
  }

  function toHexString(
    address addr
  ) internal
    pure
    returns (string memory) {
    return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Safe ERC 20 Library
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library makes use of bool success on transfer, transferFrom and approve of EIP 20
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >= 0.8.0 < 0.9.0;

import "../eip/20/IERC20.sol";

library Safe20 {

  error MaxSplaining(string reason);

  function safeTransfer(
    IERC20 token
  , address to
  , uint256 amount
  ) internal {
    if (!token.transfer(to, amount)) {
      revert MaxSplaining({
        reason: "Safe20: token.transfer failed"
      });
    }
  }

  function safeTransferFrom(
    IERC20 token
  , address from
  , address to
  , uint256 amount
  ) internal {
    if (!token.transferFrom(from, to, amount)) {
      revert MaxSplaining({
        reason: "Safe20: token.transferFrom failed"
      });
    }
  }

  function safeApprove(
    IERC20 token
  , address spender
  , uint256 amount
  ) internal {
    if (!token.approve(spender, amount)) {
      revert MaxSplaining({
        reason: "Safe20: token.approve failed"
      });
    }
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Roles.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library for MaxAcess.sol
 * @custom:error-code Roles:1 User has role already
 * @custom:error-code Roles:2 User does not have role to revoke
 * @custom:change-log custom errors added above
 * @custom:change-log cleaned up variables
 * @custom:change-log internal -> internal/internal
 *
 * Include with 'using Roles for Roles.Role;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library Roles {

  bytes4 constant internal DEVS = 0xca4b208b;
  bytes4 constant internal OWNERS = 0x8da5cb5b;
  bytes4 constant internal ADMIN = 0xf851a440;

  struct Role {
    mapping(address => mapping(bytes4 => bool)) bearer;
    address owner;
    address developer;
    address admin;
  }

  event RoleChanged(bytes4 _role, address _user, bool _status);
  event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event DeveloperTransferred(address indexed previousDeveloper, address indexed newDeveloper);

  error Unauthorized();
  error MaxSplaining(string reason);

  function add(
    Role storage role
  , bytes4 userRole
  , address account
  ) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (has(role, userRole, account)) {
      revert MaxSplaining({
        reason: "Roles:1"
      });
    }
    role.bearer[account][userRole] = true;
    emit RoleChanged(userRole, account, true);
  }

  function remove(
    Role storage role
  , bytes4 userRole
  , address account
  ) internal {
    if (account == address(0)) {
      revert Unauthorized();
    } else if (!has(role, userRole, account)) {
      revert MaxSplaining({
        reason: "Roles:2"
      });
    }
    role.bearer[account][userRole] = false;
    emit RoleChanged(userRole, account, false);
  }

  function has(
    Role storage role
  , bytes4  userRole
  , address account
  ) internal
    view
    returns (bool) {
    if (account == address(0)) {
      revert Unauthorized();
    }
    return role.bearer[account][userRole];
  }

  function setAdmin(
    Role storage role
  , address account
  ) internal {
    if (has(role, ADMIN, account)) {
      address old = role.admin;
      role.admin = account;
      emit AdminTransferred(old, role.admin);
    } else if (account == address(0)) {
      address old = role.admin;
      role.admin = account;
      emit AdminTransferred(old, role.admin);
    } else {
      revert Unauthorized();
    }
  }

  function setDeveloper(
    Role storage role
  , address account
  ) internal {
    if (has(role, DEVS, account)) {
      address old = role.developer;
      role.developer = account;
      emit DeveloperTransferred(old, role.developer);
    } else if (account == address(0)) {
      address old = role.admin;
      role.admin = account;
      emit AdminTransferred(old, role.admin);
    } else {
      revert Unauthorized();
    }
  }

  function setOwner(
    Role storage role
  , address account
  ) internal {
    if (has(role, OWNERS, account)) {
      address old = role.owner;
      role.owner = account;
      emit OwnershipTransferred(old, role.owner);
    } else if (account == address(0)) {
      address old = role.admin;
      role.admin = account;
      emit AdminTransferred(old, role.admin);
    } else {
      revert Unauthorized();
    }
  }

  function getAdmin(
    Role storage role
  ) internal 
    view
    returns (address) {
    return role.admin;
  }

  function getDeveloper(
    Role storage role
  ) internal
    view
    returns (address) {
    return role.developer;
  }

  function getOwner(
    Role storage role
  ) internal
    view
    returns (address) {
    return role.owner;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP]: NFT Minting engine, by using bookend mints
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Given tokenId's from [0...X] find a psuedorandom start Y. Then
 *          Mint from Y -> X, 0 -> Y by using modulo division!
 *          Used in LaidBackLlamas, DaemonDao, American Gothic...
 * @custom:error-code PR:E1 "Max Capacity not set" - required for psuedorandom number genesis
 * @custom:change-log custom error added above
 * @custom:change-log internal -> internal
 *
 * Include with 'using PsuedoRand for PsuedoRand.Engine;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library PsuedoRand {

  using CountersV2 for CountersV2.Counter;

  struct Engine {
    uint256 mintFee;
    uint256 startNumber;
    uint256 maxCapacity;
    uint256 maxTeamMints;
    string ProvenanceIMG;
    string ProvenanceJSON;
    CountersV2.Counter currentMinted;
    CountersV2.Counter currentTeam;
    bool status;
    bool provSet;
  }

  event SetProvenanceIMG(string _new, string _old);
  event SetProvenanceJSON(string _new, string _old);
  event SetStartNumber(uint _new);
  event SetMaxCapacity(uint _new, uint _old);
  event SetMaxTeamMint(uint _new, uint _old);
  event SetMintFees(uint _new, uint _old);
  event SetStatus(bool _new);
  event ProvenanceLocked(bool _status);

  error MaxSplaining(string reason);

  function setProvJSON(
    Engine storage engine
  , string memory provJSON
  ) internal {
    string memory old = engine.ProvenanceJSON;
    engine.ProvenanceJSON = provJSON;
    emit SetProvenanceJSON(provJSON, old);
  }
 
  function setProvIMG(
    Engine storage engine
  , string memory provIMG
  ) internal {
    string memory old = engine.ProvenanceIMG;
    engine.ProvenanceIMG = provIMG;
    emit SetProvenanceIMG(provIMG, old);
  }

  function provLock(
    Engine storage engine
  ) internal {
    engine.provSet = true;
    emit ProvenanceLocked(engine.provSet);
  }

  function setStartNumber(
    Engine storage engine
  ) internal {
    if (engine.maxCapacity == 0) {
      revert MaxSplaining({
        reason : "PR:E1"
      });
    }
    engine.startNumber = uint(
                           keccak256(
                             abi.encodePacked(
                               block.timestamp
                             , msg.sender
                             , engine.ProvenanceIMG
                             , engine.ProvenanceJSON
                             , block.difficulty))) 
                         % engine.maxCapacity;
    emit SetStartNumber(engine.startNumber);
  }

  function setMaxCap(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxCapacity;
    engine.maxCapacity = max;
    emit SetMaxCapacity(max, old);
  }

  function setMaxTeam(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.maxTeamMints;
    engine.maxTeamMints = max;
    emit SetMaxTeamMint(max, old);
  }

  function setFees(
    Engine storage engine
  , uint256 max
  ) internal {
    uint old = engine.mintFee;
    engine.mintFee = max;
    emit SetMintFees(max, old);
  }

  function setStatus(
    Engine storage engine
  , bool change
  ) internal {
    engine.status = change;
    emit SetStatus(change);
  }

  function showProvenanceImages(
    Engine storage engine
  ) internal
    view
    returns (string memory) {
    return engine.ProvenanceIMG;
  }

  function showProvenanceJSON(
    Engine storage engine
  ) internal
    view
    returns (string memory) {
    return engine.ProvenanceJSON;
  }

  function showStartID(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.startNumber;
  }

  function showStatus(
    Engine storage engine
  ) internal
    view
    returns (bool) {
    return engine.status;
  }

  function showFees(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.mintFee;
  }

  function showCapacity(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.maxCapacity;
  }

  function showTeamMints(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.maxTeamMints;
  }

  function showCurrentMinted(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.currentMinted.current();
  }

  function showCurrentTeam(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.currentTeam.current();
  }

  function mintID(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return (engine.startNumber + engine.currentMinted.current()) % engine.maxCapacity;
  }

  function showTeam(
    Engine storage engine
  ) internal 
    view
    returns (uint256) {
    return engine.currentTeam.current();
  }

  function showMinted(
    Engine storage engine
  ) internal
    view
    returns (uint256) {
    return engine.currentMinted.current();
  }

  function battersUpTeam(
    Engine storage engine
  ) internal {
    engine.currentTeam.increment();
  }

  function battersUp(
    Engine storage engine
  ) internal {
    engine.currentMinted.increment();
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Payment Splitter
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library for two structs one with "ERC-20's" and one without
 * @custom:error-code PS:1 No Shares for address
 * @custom:error-code PS:2 No payment due for address
 * @custom:error-code PS:3 Can not use address(0)
 * @custom:error-code PS:4 Shares can not be 0
 * @custom:error-code PS:5 User has shares already
 * @custom:error-code PS:6 User not in payees
 * @custom:error-code PS:7 ERC-20 can not be address(0)
 * @custom:error-code PS:8 ERC-20 already in authorized list
 * @custom:error-code PS:9 ERC-20 not in authorized list
 * @custom:change-log added custom error-codes above
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library Payments {

  struct GasTokens {
    uint256 totalShares;
    uint256 totalReleased;
    mapping(address => uint256) shares;
    mapping(address => uint256) released;
    address[] payees;
  }

  struct AllTokens {
    uint256 totalShares;
    uint256 totalReleased;
    mapping(address => uint256) shares;
    mapping(address => uint256) released;
    mapping(address => uint256) erc20TotalReleased;
    mapping(address => mapping(address => uint256)) erc20Released;
    address[] payees;
    address[] tokens;
  }

  event PayeeAdded(address account, uint256 _shares);
  event PayeeRemoved(address account, uint256 _shares);
  event PayeesReset();
  event TokenAdded(address indexed token);
  event TokenRemoved(address indexed token);
  event TokensReset();
  event PaymentReleased(address to, uint256 amount);
  event ERC20PaymentReleased(address indexed token, address to, uint256 amount);

  error MaxSplaining(string reason);

  function findIndex(
    address[] memory array
  , address query
  ) internal
    pure
    returns (bool found, uint256 index) {
    uint256 len = array.length;
    for (uint x = 0; x < len;) {
      if (array[x] == query) {
        found = true;
        index = x;
      }
      unchecked { ++x; }
    }
  }

  // GasTokens

  function getTotalReleased(
    GasTokens storage gasTokens
  ) internal
    view
    returns (uint256) {
    return gasTokens.totalReleased;
  }

  function getTotalShares(
    GasTokens storage gasTokens
  ) internal
    view
    returns (uint256) {
    return gasTokens.totalShares;
  }

  function payeeShares(
    GasTokens storage gasTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    return gasTokens.shares[payee];
  }

  function payeeReleased(
    GasTokens storage gasTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    return gasTokens.released[payee];
  }

  function payeeIndex(
    GasTokens storage gasTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    (bool found, uint256 index) = findIndex(gasTokens.payees, payee);
    if (found) {
      return index;
    } else {
      revert MaxSplaining({
        reason: "PS:6"
      });
    }
  }

  function allPayees(
    GasTokens storage gasTokens
  ) internal
    view
    returns (address[] memory) {
    return gasTokens.payees;
  }

  function addPayee(
    GasTokens storage gasTokens
  , address payee
  , uint256 _shares
  ) internal {
    if (payee == address(0)) {
      revert MaxSplaining({
        reason: "PS:3"
      });
    } else if (_shares == 0) {
      revert MaxSplaining({
        reason: "PS:4"
      });
    } else if (gasTokens.shares[payee] > 0) {
      revert MaxSplaining({
        reason: "PS:5"
      });
    }
    gasTokens.payees.push(payee);
    gasTokens.shares[payee] = _shares;
    gasTokens.totalShares += _shares;
    emit PayeeAdded(payee, _shares);
  }

  function removePayee(
    GasTokens storage gasTokens
  , address payee
  ) internal {
    if (payee == address(0)) {
      revert MaxSplaining({
        reason: "PS:3"
      });
    }
    uint256 whacked = payeeIndex(gasTokens, payee);
    address last = gasTokens.payees[gasTokens.payees.length -1];
    gasTokens.payees[whacked] = last;
    gasTokens.payees.pop();
    uint256 whackedShares = gasTokens.shares[payee];
    delete gasTokens.shares[payee];
    gasTokens.totalShares -= whackedShares;
    emit PayeeRemoved(payee, whackedShares);
  }

  function clearPayees(
    GasTokens storage gasTokens
  ) internal {
    uint256 len = gasTokens.payees.length;
    for (uint x = 0; x < len;) {
      address whacked = gasTokens.payees[x];
      delete gasTokens.shares[whacked];
      unchecked { ++x; }
    }
    delete gasTokens.totalShares;
    delete gasTokens.payees;
    emit PayeesReset();
  }

  function processPayment(
    GasTokens storage gasTokens
  , address payee
  , uint256 payment
  ) internal {
    gasTokens.totalReleased += payment;
    gasTokens.released[payee] += payment;
    emit PaymentReleased(payee, payment);
  }

  // AllTokens

  function getTotalReleased(
    AllTokens storage allTokens
  ) internal
    view
    returns (uint256) {
    return allTokens.totalReleased;
  }

  function getTotalReleased(
    AllTokens storage allTokens
  , address _token
  ) internal
    view
    returns (uint256) {
    return allTokens.erc20TotalReleased[_token];
  }

  function getTotalShares(
    AllTokens storage allTokens
  ) internal
    view
    returns (uint256) {
    return allTokens.totalShares;
  }

  function payeeShares(
    AllTokens storage allTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    return allTokens.shares[payee];
  }

  function payeeReleased(
    AllTokens storage allTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    return allTokens.released[payee];
  }

  function payeeReleased(
    AllTokens storage allTokens
  , address _token
  , address payee
  ) internal
    view
    returns (uint256) {
    return allTokens.erc20Released[_token][payee];
  }

  function payeeIndex(
    AllTokens storage allTokens
  , address payee
  ) internal
    view
    returns (uint256) {
    (bool found, uint256 index) = findIndex(allTokens.payees, payee);
    if (found) {
      return index;
    } else {
      revert MaxSplaining({
        reason: "PS:6"
      });
    }
  }

  function tokenIndex(
    AllTokens storage allTokens
  , address _token
  ) internal
    view
    returns (uint256) {
    (bool found, uint256 index) = findIndex(allTokens.tokens, _token);
    if (found) {
      return index;
    } else {
      revert MaxSplaining({
        reason: "PS:9"
      });
    }
  }

  function getPayees(
    AllTokens storage allTokens
  ) internal
    view
    returns (address[] memory) {
    return allTokens.payees;
  }

  function getTokens(
    AllTokens storage allTokens
  ) internal
    view
    returns (address[] memory) {
    return allTokens.tokens;
  }

  function addPayee(
    AllTokens storage allTokens
  , address payee
  , uint256 _shares
  ) internal {
    if (payee == address(0)) {
      revert MaxSplaining({
        reason: "PS:3"
      });
    } else if (_shares == 0) {
      revert MaxSplaining({
        reason: "PS:4"
      });
    } else if (allTokens.shares[payee] > 0) {
      revert MaxSplaining({
        reason: "PS:5"
      });
    }
    allTokens.payees.push(payee);
    allTokens.shares[payee] = _shares;
    allTokens.totalShares += _shares;
    emit PayeeAdded(payee, _shares);
  }

  function addToken(
    AllTokens storage allTokens
  , address _token
  ) internal {
    if (_token == address(0)) {
      revert MaxSplaining({
        reason: "PS:7"
      });
    } 
    (bool check, ) = findIndex(allTokens.tokens, _token);
    if (check) {
      revert MaxSplaining({
        reason: "PS:8"
      });
    }
    allTokens.tokens.push(_token);
    emit TokenAdded(_token);
  }

  function removePayee(
    AllTokens storage allTokens
  , address payee
  ) internal {
    if (payee == address(0)) {
      revert MaxSplaining({
        reason: "PS:3"
      });
    }
    uint256 whacked = payeeIndex(allTokens, payee);
    address last = allTokens.payees[allTokens.payees.length -1];
    allTokens.payees[whacked] = last;
    allTokens.payees.pop();
    uint256 whackedShares = allTokens.shares[payee];
    delete allTokens.shares[payee];
    allTokens.totalShares -= whackedShares;
    emit PayeeRemoved(payee, whackedShares);
  }

  function removeToken(
    AllTokens storage allTokens
  , address _token
  ) internal {
    if (_token == address(0)) {
      revert MaxSplaining({
        reason: "PS:7"
      });
    }
    (bool check, uint256 whacked) = findIndex(allTokens.tokens, _token);
    if (!check) {
      revert MaxSplaining({
        reason: "PS:9"
      });
    }
    address last = allTokens.tokens[allTokens.tokens.length -1];
    allTokens.payees[whacked] = last;
    allTokens.payees.pop();
    emit TokenRemoved(_token);
  }

  function clearPayees(
    AllTokens storage allTokens
  ) internal {
    uint256 len = allTokens.payees.length;
    for (uint x = 0; x < len;) {
      address whacked = allTokens.payees[x];
      delete allTokens.shares[whacked];
      unchecked { ++x; }
    }
    delete allTokens.totalShares;
    delete allTokens.payees;
    emit PayeesReset();
  }

  function clearTokens(
    AllTokens storage allTokens
  ) internal {
    delete allTokens.tokens;
    emit TokensReset();
  }

  function processPayment(
    AllTokens storage allTokens
  , address payee
  , uint256 payment
  ) internal {
    allTokens.totalReleased += payment;
    allTokens.released[payee] += payment;
    emit PaymentReleased(payee, payment);
  }

  function processPayment(
    AllTokens storage allTokens
  , address payee
  , uint256 payment
  , address _token
  ) internal {
    allTokens.erc20TotalReleased[_token] += payment;
    allTokens.erc20Released[_token][payee] += payment;
    emit ERC20PaymentReleased(_token, payee, payment);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP]: Access lists
 * @author: @MaxFlowO2 on bird app/GitHub
 * @dev Formerly whitelists, now allowlist, or whatever it's called.
 * @custom:change-log removed end variable/functions (un-needed)
 * @custom:change-log variables renamed from lib whitelist
 * @custom:change-log internal -> internal
 * @custom:error-code Lists:1 "(user) is already whitelisted."
 * @custom:error-code Lists:2 "(user) is not whitelisted."
 * @custom:error-code Lists:3 "Whitelist already enabled."
 * @custom:error-code Lists:4 "Whitelist already disabled."
 * @custom:change-log added custom error codes
 * @custom:change-log removed import "./Strings.sol"; (un-needed)
 *
 * Include with 'using Lists for Lists.Access;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";

library Lists {

  using CountersV2 for CountersV2.Counter;

  event ListChanged(bool _old, bool _new, address _address);
  event ListStatus(bool _old, bool _new);

  error MaxSplaining(string reason);

  struct Access {
    bool _status;
    CountersV2.Counter added;
    CountersV2.Counter removed;
    mapping(address => bool) allowed;
  }

  function add(
    Access storage list
  , address user
  ) internal {
    if (list.allowed[user]) {
      revert  MaxSplaining({
        reason : "Lists:1"
      });
    }
    // since now all previous values are false no need for another variable
    // and add them to the list!
    list.allowed[user] = true;
    // increment counter
    list.added.increment();
    // emit event
    emit ListChanged(false, list.allowed[user], user);
  }

  function remove(
    Access storage list
  , address user
  ) internal {
    if (!list.allowed[user]) {
      revert  MaxSplaining({
        reason : "Lists:2"
      });
    }
    // since now all previous values are true no need for another variable
    // and remove them from the list!
    list.allowed[user] = false;
    // increment counter
    list.removed.increment();
    // emit event
    emit ListChanged(true, list.allowed[user], user);
  }

  function enable(
    Access storage list
  ) internal {
    if (list._status) {
      revert  MaxSplaining({
        reason : "Lists:3"
      });
    }
    list._status = true;
    emit ListStatus(false, list._status);
  }

  function disable(
    Access storage list
  ) internal {
    if (!list._status) {
      revert  MaxSplaining({
        reason : "Lists:4"
      });
    }
    list._status = false;
    emit ListStatus(true, list._status);
  }

  function status(
    Access storage list
  ) internal
    view
    returns (bool) {
    return list._status;
  }

  function totalAdded(
    Access storage list
  ) internal
    view
    returns (uint) {
    return list.added.current();
  }

  function totalRemoved(
    Access storage list
  ) internal
    view
    returns (uint) {
    return list.removed.current();
  }

  function onList(
    Access storage list
  , address user
  ) internal
    view
    returns (bool) {
    return list.allowed[user];
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: CountersV2.sol
 * @author Matt Condon (@shrugs)
 * @notice Provides counters that can only be incremented, decremented, reset or set. 
 * This can be used e.g. to track the number of elements in a mapping, issuing ERC721 ids
 * or counting request ids.
 * @custom:change-log MIT -> Apache-2.0
 * @custom:change-log Edited for more NFT functionality added .set(uint)
 * @custom:change-log added event CounterNumberChangedTo(uint _number).
 * @custom:change-log added error MaxSplaining(string reason).
 * @custom:change-log internal -> internal functions
 * @custom:error-code CountersV2:1 "No negatives in uints" - overflow protection
 *
 * Include with `using CountersV2 for CountersV2.Counter;`
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library CountersV2 {

  struct Counter {
    uint256 value;
  }

  event CounterNumberChangedTo(uint _number);

  error MaxSplaining(string reason);

  function current(
    Counter storage counter
  ) internal
    view
    returns (uint256) {
    return counter.value;
  }

  function increment(
    Counter storage counter
  ) internal {
    unchecked {
      ++counter.value;
    }
  }

  function decrement(
    Counter storage counter
  ) internal {
    if (counter.value == 0) {
      revert MaxSplaining({
        reason : "CountersV2:1"
      });
    }
    unchecked {
      --counter.value;
    }
  }

  function reset(
    Counter storage counter
  ) internal {
    counter.value = 0;
    emit CounterNumberChangedTo(counter.value);
  }

  function set(
    Counter storage counter
  , uint number
  ) internal {
    counter.value = number;
    emit CounterNumberChangedTo(counter.value);
  }  
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Library 721
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library for EIP 721
 * @custom:error-code Lib721:1 "non-existent tokenId" 
 * @custom:error-code Lib721:2 "approval to current owner"
 * @custom:error-code Lib721:3 "approve caller is not token owner nor approved for all"
 * @custom:error-code Lib721:4 "approve to caller"
 * @custom:error-code Lib721:5 "caller is not token owner nor approved"
 * @custom:error-code Lib721:6 "transfer from incorrect owner"
 * @custom:error-code Lib721:7 "transfer to the zero address"
 * @custom:error-code Lib721:8 "mint to the zero address"
 * @custom:error-code Lib721:9 "token already minted"
 * @custom:change-log Custom errors added above
 *
 * Include with 'using Lib721 for Lib721.Token;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./Strings.sol";
import "./CountersV2.sol";

library Lib721 {

  using Strings for uint256;
  using CountersV2 for CountersV2.Counter;

  struct Token {
    string name;
    string symbol;
    string baseURI;
    CountersV2.Counter supply;
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
  }

  event NameSet(string name);
  event SymbolSet(string symbol);
  event NewBaseURI(string baseURI);
  event Approval(address owner, address to, uint256 tokenId);
  event ApprovalForAll(address owner, address operator, bool approved);
  event Transfer(address from, address to, uint256 tokenId);

  error MaxSplaining(string reason);

  function getBalanceOf(
    Token storage token
  , address owner
  ) internal
    view
    returns (uint256) {
    return token.balances[owner];
  }

  function getOwnerOf(
    Token storage token
  , uint256 tokenId
  ) internal 
    view
    returns (address) {
    return token.owners[tokenId];
  }

  function setName(
    Token storage token
  , string memory newName
  ) internal {
    token.name = newName;
    emit NameSet(newName);
  }

  function getName(
   Token storage token
  ) internal
    view
    returns (string memory) {
    return token.name;
  }

  function setSymbol(
    Token storage token
  , string memory newSymbol
  ) internal {
    token.symbol = newSymbol;
    emit SymbolSet(newSymbol);
  }

  function getSymbol(
   Token storage token
  ) internal
    view
    returns (string memory) {
    return token.symbol;
  }

  function getSupply(
   Token storage token
  ) internal
    view
    returns (uint256) {
    return token.supply.current();
  }

  function setBaseURI(
    Token storage token
  , string memory newURI
  ) internal {
    token.baseURI = newURI;
    emit NewBaseURI(newURI);
  }

  function getTokenURI(
    Token storage token
  , uint256 tokenId
  ) internal
    view
    returns (string memory) {
    if (getOwnerOf(token, tokenId) == address(0)) {
      revert MaxSplaining({
        reason: "Lib721:1"
      });
    }
    return bytes(token.baseURI).length > 0 ? string(abi.encodePacked(token.baseURI, tokenId.toString())) : "";
  }

  function setApprove(
    Token storage token
  , address to
  , uint256 tokenId
  ) internal {
    address owner = getOwnerOf(token, tokenId);
    if (to == owner) {
      revert MaxSplaining({
        reason: "Lib721:2"
      });
    } else if (msg.sender != owner || !isApprovedForAll(token, owner, msg.sender)) {
      revert MaxSplaining({
        reason: "Lib721:3"
      });
    }
    token.tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  function getApproved(
    Token storage token
  , uint256 tokenId
  ) internal
    view
    returns (address) {
    if (getOwnerOf(token, tokenId) == address(0)) {
      revert MaxSplaining({
        reason: "Lib721:1"
      });
    }
    return token.tokenApprovals[tokenId];
  }

  function setApprovalForAll(
    Token storage token
  , address operator
  , bool approved
  ) internal {
    if (msg.sender == operator) {
      revert MaxSplaining({
        reason: "Lib721:4"
      });
    }
    token.operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function isApprovedForAll(
    Token storage token
  , address owner
  , address operator
  ) internal
    view
    returns (bool) {
    return token.operatorApprovals[owner][operator];
  }

  function isApprovedOrOwner(
    Token storage token
  , address spender
  , uint256 tokenId
  ) internal
    view
    returns (bool) {
    address owner = getOwnerOf(token, tokenId);
    return (
      spender == owner ||
      isApprovedForAll(token, owner, spender) ||
      getApproved(token, tokenId) == spender
    );
  }

  function doTransferFrom(
    Token storage token
  , address from
  , address to
  , uint256 tokenId
  ) internal {
    if (!isApprovedOrOwner(token, msg.sender, tokenId)) {
      revert MaxSplaining({
        reason: "Lib721:5"
      });
    }
    address owner = getOwnerOf(token, tokenId);
    if (owner != from) {
      revert MaxSplaining({
        reason: "Lib721:6"
      });
    } else if (to == address(0)) {
      revert MaxSplaining({
        reason: "Lib721:7"
      });
    }
    // Clear approvals from the previous owner
    setApprove(token, address(0), tokenId);
    // Change balances
    token.balances[from] -= 1;
    token.balances[to] += 1;
    // Move tokenId
    token.owners[tokenId] = to;
    emit Transfer(from, to, tokenId);
  }

  function mint(
    Token storage token
  , address to
  , uint256 tokenId
  ) internal {
    if (to == address(0)) {
      revert MaxSplaining({
        reason: "Lib721:8"
      });
    } else if (getOwnerOf(token, tokenId) != address(0)) {
      revert MaxSplaining({
        reason: "Lib721:9"
      });
    }
    token.balances[to] += 1;
    token.owners[tokenId] = to;
    token.supply.increment();
    emit Transfer(address(0), to, tokenId);
  }

  function burn(
    Token storage token
  , uint256 tokenId
  ) internal {
    address owner = getOwnerOf(token, tokenId);
    // Clear approvals
    setApprove(token, address(0), tokenId);
    // Change balances
    token.balances[owner] -= 1;
    delete token.owners[tokenId];
    token.supply.decrement();
    emit Transfer(owner, address(0), tokenId);
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: Library 2981
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Library for EIP 2981
 * @custom:error-code
 * @custom:change-log Custom errors added above
 *
 * Include with 'using Lib2981 for Lib2981.Royalties;' -- unique per collection
 * Include with 'using Lib2981 for Lib2981.MappedRoyalties;' -- unique per token
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

library Lib2981 {

  struct Royalties {
    address receiver;
    uint16 permille;
  }

  struct MappedRoyalties {
    mapping(uint256 => Royalties) royalty;
  }

  event RoyaltiesSet(uint256 token, address recipient, uint16 value);
  event RoyaltiesSet(address recipient, uint16 value);

  error MaxSplaining(string reason);

  // For MappedRoyalties struct (of Royalties)

  function setRoyalties(
    MappedRoyalties storage royalties
  , uint256 tokenId
  , address receiver
  , uint16 permille
  ) internal {
    if (permille >= 1000 ||  permille == 0) {
      revert MaxSplaining({
        reason: "Lib2981:1"
      });
    }
    royalties.royalty[tokenId] = Royalties(receiver, permille);
    emit RoyaltiesSet(
           tokenId
         , royalties.royalty[tokenId].receiver
         , royalties.royalty[tokenId].permille
         );
  }

  function revokeRoyalties(
    MappedRoyalties storage royalties
  , uint256 tokenId
  ) internal {
    delete royalties.royalty[tokenId];
    emit RoyaltiesSet(
           tokenId
         , royalties.royalty[tokenId].receiver
         , royalties.royalty[tokenId].permille
         );
  }

  function royaltyInfo(
    MappedRoyalties storage royalties
  , uint256 tokenId
  , uint256 salePrice
  ) internal
    view
    returns (
      address receiver
    , uint256 royaltyAmount
    ) {
    receiver = royalties.royalty[tokenId].receiver;
    royaltyAmount = salePrice * royalties.royalty[tokenId].permille / 1000;
  }

  // For Royalties struct only

  function setRoyalties(
    Royalties storage royalties
  , address receiver
  , uint16 permille
  ) internal {
    if (permille >= 1000 ||  permille == 0) {
      revert MaxSplaining({
        reason: "Lib2981:1"
      });
    }
    royalties.receiver = receiver;
    royalties.permille = permille;
    emit RoyaltiesSet(
           royalties.receiver
         , royalties.permille
         );
  }

  function revokeRoyalties(
    Royalties storage royalties
  ) internal {
    delete royalties.receiver;
    delete royalties.permille;
    emit RoyaltiesSet(
           royalties.receiver
         , royalties.permille
         );
  }

  function royaltyInfo(
    Royalties storage royalties
  , uint256 tokenId
  , uint256 salePrice
  ) internal
    view
    returns (
      address receiver
    , uint256 royaltyAmount
    ) {
    receiver = royalties.receiver;
    royaltyAmount = salePrice * royalties.permille / 1000;
  }
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP]: MaxErrors, so I can import errors, anywhere minus libraries
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Does not have an ERC165 return since no external/public functions
 * @custom:change-log abstract contract -> interface
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

interface MaxErrors {

  /// @dev this is Unauthorized(), basically a catch all, zero description
  /// @notice 0x82b42900 bytes4 of this
  error Unauthorized();

  /// @dev this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  /// @param reason: Use the "Contract name: error"
  /// @notice 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  /// @dev this is TooSoonJunior(), using times
  /// @param yourTime: should almost always be block.timestamp
  /// @param hitTime: the time you should have started
  /// @notice 0xf3f82ac5 bytes4 of this
  error TooSoonJunior(
    uint yourTime
  , uint hitTime
  );

  /// @dev this is TooLateBoomer(), using times
  /// @param yourTime: should almost always be block.timestamp
  /// @param hitTime: the time you should have ended
  /// @notice 0x43c540ef bytes4 of this
  error TooLateBoomer(
    uint yourTime
  , uint hitTime
  );

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC-721 Non-Fungible Token Standard, required wallet interface
 * @author: William Entriken, Dieter Shirley, Jacob Evans, Nastassia Sachs
 * @dev the ERC-165 identifier for this interface is 0x150b7a02.
 * @custom:source https://eips.ethereum.org/EIPS/eip-721
 * @custom:change-log interface ERC721TokenReceiver -> interface IERC721TokenReceiver
 * @custom:change-log readability enhanced
 * @custom:change-log MIT -> Apache-2.0
 * @custom:change-log TypeError: Data location must be "memory" or "calldata" for parameter (line 60)
 *
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../165/IERC165.sol";

interface IERC721TokenReceiver is IERC165 {

  /// @notice Handle the receipt of an NFT
  /// @notice The ERC721 smart contract calls this function on the recipient
  ///  after a `transfer`. This function MAY throw to revert and reject the
  ///  transfer. Return of other than the magic value MUST result in the
  ///  transaction being reverted.
  ///  Note: the contract address is always the message sender.
  /// @param _operator The address which called `safeTransferFrom` function
  /// @param _from The address which previously owned the token
  /// @param _tokenId The NFT identifier which is being transferred
  /// @param _data Additional data with no specified format
  /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  ///  unless throwing
  function onERC721Received(
    address _operator
  , address _from
  , uint256 _tokenId
  , bytes calldata _data
  ) external
    returns(bytes4);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @author: William Entriken, Dieter Shirley, Jacob Evans, Nastassia Sachs
 * @dev the ERC-165 identifier for this interface is 0x5b5e139f.
 * @custom:source https://eips.ethereum.org/EIPS/eip-721
 * @custom:change-log interface ERC721Metadata * is ERC721 * -> interface IERC721Metadata
 * @custom:change-log readability enhanced
 * @custom:change-log MIT -> Apache-2.0
 * @custom:change-log  Data location must be "memory" or "calldata" for return parameter (lines 48, 54, 64)
 *
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {

  /// @notice A descriptive name for a collection of NFTs in this contract
  function name()
    external
    view
    returns (string memory _name);

  /// @notice An abbreviated name for NFTs in this contract
  function symbol()
    external
    view
    returns (string memory _symbol);

  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
  /// @notice Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  function tokenURI(
    uint256 _tokenId
  ) external
    view
    returns (string memory);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @author: William Entriken, Dieter Shirley, Jacob Evans, Nastassia Sachs
 * @dev the ERC-165 identifier for this interface is 0x780e9d63.
 * @custom:source https://eips.ethereum.org/EIPS/eip-721
 * @custom:change-log interface ERC721Enumerable * is ERC721 * -> interface IERC721Enumerable
 * @custom:change-log readability enhanced
 * @custom:change-log MIT -> Apache-2.0
 *
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./IERC721Metadata.sol";

interface IERC721Enumerable is IERC721Metadata {

  /// @notice Count NFTs tracked by this contract
  /// @return A count of valid NFTs tracked by this contract, where each one of
  ///  them has an assigned and queryable owner not equal to the zero address
  function totalSupply()
    external
    view
    returns (uint256);

  /// @notice Enumerate valid NFTs
  /// @notice Throws if `_index` >= `totalSupply()`.
  /// @param _index A counter less than `totalSupply()`
  /// @return The token identifier for the `_index`th NFT,
  ///  (sort order not specified)
  function tokenByIndex(
    uint256 _index
  ) external
    view
    returns (uint256);

  /// @notice Enumerate NFTs assigned to an owner
  /// @notice Throws if `_index` >= `balanceOf(_owner)` or if
  ///  `_owner` is the zero address, representing invalid NFTs.
  /// @param _owner An address where we are interested in NFTs owned by them
  /// @param _index A counter less than `balanceOf(_owner)`
  /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
  ///   (sort order not specified)
  function tokenOfOwnerByIndex(
    address _owner
  , uint256 _index
  ) external
    view
    returns (uint256);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: ERC-721 Non-Fungible Token Standard
 * @author: William Entriken, Dieter Shirley, Jacob Evans, Nastassia Sachs
 * @dev the ERC-165 identifier for this interface is 0x80ac58cd.
 * @custom:source https://eips.ethereum.org/EIPS/eip-721
 * @custom:change-log interface ERC721 * is ERC165 * -> interface IERC721
 * @custom:change-log removed payable from IERC721 
 * @custom:change-log removed events from IERC721 (handled in Lib721)
 * @custom:change-log readability enhanced
 * @custom:change-log MIT -> Apache-2.0
 * @custom:change-log TypeError: Data location must be "memory" or "calldata" for parameter (line 84)
 *
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../165/IERC165.sol";

interface IERC721 is IERC165 {

  /// @notice Count all NFTs assigned to an owner
  /// @notice NFTs assigned to the zero address are considered invalid, and this
  ///  function throws for queries about the zero address.
  /// @param _owner An address for whom to query the balance
  /// @return The number of NFTs owned by `_owner`, possibly zero
  function balanceOf(
    address _owner
  ) external
    view
    returns (uint256);

  /// @notice Find the owner of an NFT
  /// @notice NFTs assigned to zero address are considered invalid, and queries
  ///  about them do throw.
  /// @param _tokenId The identifier for an NFT
  /// @return The address of the owner of the NFT
  function ownerOf(
    uint256 _tokenId
  ) external
    view
    returns (address);

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @notice Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  /// @param data Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  , bytes calldata data
  ) external;

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @notice This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to "".
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  ) external;

  /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  /// @notice Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function transferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  ) external;

  /// @notice Change or reaffirm the approved address for an NFT
  /// @notice The zero address indicates there is no approved address.
  ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @param _approved The new approved NFT controller
  /// @param _tokenId The NFT to approve
  function approve(
    address _approved
  , uint256 _tokenId
  ) external;

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all of `msg.sender`'s assets
  /// @notice Emits the ApprovalForAll event. The contract MUST allow
  ///  multiple operators per owner.
  /// @param _operator Address to add to the set of authorized operators
  /// @param _approved True if the operator is approved, false to revoke approval
  function setApprovalForAll(
    address _operator
  , bool _approved
  ) external;

  /// @notice Get the approved address for a single NFT
  /// @notice Throws if `_tokenId` is not a valid NFT.
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(
    uint256 _tokenId
  ) external
    view
    returns (address);

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(
    address _owner
  , address _operator
  ) external
    view
    returns (bool);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title:  EIP-20: Token Standard 
 * @author: Fabian Vogelsteller, Vitalik Buterin
 * @dev The following standard allows for the implementation of a standard API for tokens within
 *      smart contracts. This standard provides basic functionality to transfer tokens, as well
 *      as allow tokens to be approved so they can be spent by another on-chain third party.
 * @custom:source https://eips.ethereum.org/EIPS/eip-20
 * @custom:change-log external -> external, string -> string memory (0.8.x)
 * @custom:change-log readability enhanced
 * @custom:change-log backwards compatability to EIP 165 added
 * @custom:change-log MIT -> Apache-2.0

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../165/IERC165.sol";

interface IERC20 is IERC165 {

  /// @dev Transfer Event
  /// @notice MUST trigger when tokens are transferred, including zero value transfers.
  /// @notice A token contract which creates new tokens SHOULD trigger a Transfer event
  ///         with the _from address set to 0x0 when tokens are created.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /// @dev Approval Event
  /// @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  /// @dev OPTIONAL - This method can be used to improve usability, but interfaces and other
  ///      contracts MUST NOT expect these values to be present.
  /// @return string memory returns the name of the token - e.g. "MyToken".
  function name()
    external
    view
    returns (string memory);

  /// @dev OPTIONAL - This method can be used to improve usability, but interfaces and other
  ///      contracts MUST NOT expect these values to be present.
  /// @return string memory returns the symbol of the token. E.g. “HIX”.
  function symbol()
    external
    view
    returns (string memory);

  /// @dev OPTIONAL - This method can be used to improve usability, but interfaces and other
  ///      contracts MUST NOT expect these values to be present.
  /// @return uint8 returns the number of decimals the token uses - e.g. 8, means to divide the
  ///         token amount by 100000000 to get its user representation.
  function decimals()
    external
    view
    returns (uint8);

  /// @dev totalSupply
  /// @return uint256 returns the total token supply.
  function totalSupply()
    external
    view
    returns (uint256);

  /// @dev balanceOf
  /// @return balance returns the account balance of another account with address _owner.
  function balanceOf(
    address _owner
  ) external
    view
    returns (uint256 balance);

  /// @dev transfer
  /// @return success
  /// @notice Transfers _value amount of tokens to address _to, and MUST fire the Transfer event.
  ///         The function SHOULD throw if the message caller’s account balance does not have enough
  ///         tokens to spend.
  /// @notice Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer
  ///         event.
  function transfer(
    address _to
  , uint256 _value
  ) external
    returns (bool success);

  /// @dev transferFrom
  /// @return success
  /// @notice The transferFrom method is used for a withdraw workflow, allowing contracts to transfer
  ///         tokens on your behalf. This can be used for example to allow a contract to transfer
  ///         tokens on your behalf and/or to charge fees in sub-currencies. The function SHOULD
  ///         throw unless the _from account has deliberately authorized the sender of the message
  ///         via some mechanism.
  /// @notice Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer
  ///         event.
  function transferFrom(
    address _from
  , address _to
  , uint256 _value
  ) external
    returns (bool success);

  /// @dev approve
  /// @return success
  /// @notice Allows _spender to withdraw from your account multiple times, up to the _value amount.
  ///         If this function is called again it overwrites the current allowance with _value.
  /// @notice To prevent attack vectors like the one described here and discussed here, clients
  ///         SHOULD make sure to create user interfaces in such a way that they set the allowance
  ///         first to 0 before setting it to another value for the same spender. THOUGH The contract
  ///         itself shouldn’t enforce it, to allow backwards compatibility with contracts deployed
  ///         before
  function approve(
    address _spender
  , uint256 _value
  ) external
    returns (bool success);

  /// @dev allowance
  /// @return remaining uint256 of allowance remaining
  /// @notice Returns the amount which _spender is still allowed to withdraw from _owner.
  function allowance(
    address _owner
  , address _spender
  ) external
    view
    returns (uint256 remaining);

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: EIP-173: Contract Ownership Standard
 * @author: Nick Mudge, Dan Finlay
 * @notice: This specification defines standard functions for owning or controlling a contract.
 *          the ERC-165 identifier for this interface is 0x7f5828d0
 * @custom:URI https://eips.ethereum.org/EIPS/eip-173
 * @custom:change-log MIT -> Apache-2.0
 * @custom:change-log readability modification
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "../../eip/165/IERC165.sol";

interface IERC173 is IERC165 {

  /// @dev This emits when ownership of a contract changes.    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @notice Get the address of the owner    
  /// @return The address of the owner.
  function owner()
    view
    external
    returns(address);
	
  /// @notice Set the address of the new owner of the contract
  /// @dev Set _newOwner to address(0) to renounce any ownership.
  /// @param _newOwner The address of the new owner of the contract    
  function transferOwnership(
    address _newOwner
  ) external;	
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: EIP-165: Standard Interface Detection
 * @author: Christian Reitwießner, Nick Johnson, Fabian Vogelsteller, Jordi Baylina, Konrad Feldmeier, William Entriken
 * @dev Creates a standard method to publish and detect what interfaces a smart contract implements.
 * @custom:source https://eips.ethereum.org/EIPS/eip-165
 * @custom:change-log interface ERC165 -> interface IERC165
 * @custom:change-log readability enhanced
 * @custom:change-log MIT -> Apache-2.0

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright and related rights waived via CC0.                               *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

interface IERC165 {

  /// @notice Query if a contract implements an interface
  /// @param interfaceID The interface identifier, as specified in ERC-165
  /// @notice Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(
    bytes4 interfaceID
  ) external
    view
    returns (bool);
}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Max-721 Storage, this is the 2023 edition of Max721's
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Contract meant for storage of state, not implementations, import to next level
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity 0.8.17;

import "./lib/Roles.sol";
import "./lib/721.sol";
import "./lib/Lists.sol";
import "./lib/TimeCop.sol";
import "./lib/PsuedoRand.sol";
import "./lib/Payments.sol";

abstract contract Max721Storage2 {

  using Roles for Roles.Role;
  using Lib721 for Lib721.Token;
  using PsuedoRand for PsuedoRand.Engine;
  using Lists for Lists.Access;
  using TimeCop for TimeCop.Enforce;
  using Payments for Payments.AllTokens;

  // The Structs...
  Roles.Role internal contractRoles;
  Lib721.Token internal token721;
  Lists.Access internal allowed;
  TimeCop.Enforce internal times;
  PsuedoRand.Engine internal nftEngine;
  Payments.AllTokens internal splitter;

  // The rest (got to have a few)
  string internal thisContractURI;
  bytes4 constant internal DEVS = 0xca4b208b;
  bytes4 constant internal PENDING_DEVS = 0xca4b208a; // DEVS - 1
  bytes4 constant internal OWNERS = 0x8da5cb5b;
  bytes4 constant internal PENDING_OWNERS = 0x8da5cb5a; // OWNERS - 1
  bytes4 constant internal ADMIN = 0xf851a440;

  // UUPS filler
  uint256[37] internal __gap;

}

/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   [email protected]@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  [email protected]@*     [email protected]  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    [email protected]@-.#@#  [email protected]%#.   :.     [email protected]*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ [email protected]#.-- .*%*. .#@@*@#  %@@%*#@@: [email protected]@=-.         -%-   #%@:   +*-   =*@*   [email protected]%=:
 * @@%   =##  [email protected]@#-..%%:%[email protected]@[email protected]@+  ..   [email protected]%  #@#*[email protected]:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  [email protected]*   #@#  [email protected]@. [email protected]@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  [email protected]=  :*@:[email protected]@-:@+
 * -#%[email protected]#-  :@#@@+%[email protected]*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%[email protected]#-   :*+**+=: %%++%*
 *
 * @title: [Not an EIP] Max-721 Implementation, this is the 2023 edition of Max721's
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @dev Contract meant for implementations, not storage of state, import to next level
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity 0.8.17;

import "./Max721Storage2.sol";
import "./errors/MaxErrors.sol";
import "./eip/20/IERC20.sol";
import "./eip/721/IERC721Enumerable.sol";
import "./eip/721/IERC721TokenReceiver.sol";
import "./modules/contractURI/IContractURIAdmin.sol";
import "./modules/engine/IPsuedoRandAdmin.sol";
import "./modules/lists/IListAdmin.sol";
import "./modules/timecop/ITimeCop.sol";
import "./modules/splitter/ISplitterERC20.sol";
import "./modules/access/MaxAccess.sol";
import "./lib/Address.sol";
import "./lib/Safe20.sol";
import "./lib/Roles.sol";
import "./lib/721.sol";
import "./lib/2981.sol";
import "./lib/Lists.sol";
import "./lib/TimeCop.sol";
import "./lib/PsuedoRand.sol";
import "./lib/Payments.sol";

abstract contract Max721Implementation2 is Max721Storage2
                                         , MaxErrors
                                         , MaxAccess
                                         , IERC721Enumerable
                                         , IERC721TokenReceiver
                                         , IContractURIAdmin 
                                         , IPsuedoRandAdmin 
                                         , IListAdmin
                                         , ITimeCop 
                                         , ISplitterERC20 {

  using Roles for Roles.Role;
  using Lib721 for Lib721.Token;
  using PsuedoRand for PsuedoRand.Engine;
  using Lists for Lists.Access;
  using TimeCop for TimeCop.Enforce;
  using Payments for Payments.AllTokens;
  using Address for address;
  using Safe20 for IERC20;

  event ContractURIChange(string _old, string _new);

  ///////////////////////
  /// MAX-721: Modifiers
  ///////////////////////

  modifier onlyRole(bytes4 role) {
    if (contractRoles.has(role, msg.sender) || contractRoles.has(ADMIN, msg.sender)) {
      _;
    } else {
    revert Unauthorized();
    }
  }

  modifier onlyOwner() {
    if (contractRoles.has(OWNERS, msg.sender)) {
      _;
    } else {
    revert Unauthorized();
    }
  }

  modifier onlyDev() {
    if (contractRoles.has(DEVS, msg.sender)) {
      _;
    } else {
    revert Unauthorized();
    }
  }

  ///////////////////////
  /// MAX-721: Internals
  ///////////////////////

  function safeHook(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) internal
    returns (bool) {
    if (to.isContract()) {
      try IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data)
        returns (bytes4 retval) {
        return retval == IERC721TokenReceiver.onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert Unauthorized();
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }

  /////////////////////////////////////////
  /// EIP-173: Contract Ownership Standard
  /////////////////////////////////////////

  /// @notice Get the address of the owner    
  /// @return The address of the owner.
  function owner()
    view
    external
    returns(address) {
    return contractRoles.getOwner();
  }
	
  /// @notice Set the address of the new owner of the contract
  /// @dev Set _newOwner to address(0) to renounce any ownership.
  /// @param _newOwner The address of the new owner of the contract    
  function transferOwnership(
    address _newOwner
  ) external
    onlyRole(OWNERS) {
    contractRoles.add(OWNERS, _newOwner);
    contractRoles.setOwner(_newOwner);
    contractRoles.remove(OWNERS, msg.sender);
  }

  ////////////////////////////////////////////////////////////////
  /// EIP-173: Contract Ownership Standard, MaxFlowO2's extension
  ////////////////////////////////////////////////////////////////

  /// @dev This is the classic "EIP-173" method of renouncing onlyOwner()  
  function renounceOwnership()
    external 
    onlyRole(OWNERS) {
    contractRoles.setOwner(address(0));
    contractRoles.remove(OWNERS, msg.sender);
  }

  /// @dev This accepts the push-pull method of onlyOwner()
  function acceptOwnership()
    external
    onlyRole(PENDING_OWNERS) {
    contractRoles.add(OWNERS, msg.sender);
    contractRoles.setOwner(msg.sender);
    contractRoles.remove(PENDING_OWNERS, msg.sender);
  }

  /// @dev This declines the push-pull method of onlyOwner()
  function declineOwnership()
    external
    onlyRole(PENDING_OWNERS) {
    contractRoles.remove(PENDING_OWNERS, msg.sender);
  }

  /// @dev This starts the push-pull method of onlyOwner()
  /// @param newOwner: addres of new pending owner role
  function pushOwnership(
    address newOwner
  ) external
    onlyRole(OWNERS) {
    contractRoles.add(PENDING_OWNERS, msg.sender);
  }

  //////////////////////////////////////////////
  /// [Not an EIP]: Contract Developer Standard
  //////////////////////////////////////////////

  /// @dev Classic "EIP-173" but for onlyDev()
  /// @return Developer of contract
  function developer()
    external
    view
    returns (address) {
    return contractRoles.getDeveloper();
  }

  /// @dev This renounces your role as onlyDev()
  function renounceDeveloper()
    external
    onlyRole(DEVS) {
    contractRoles.setOwner(address(0));
    contractRoles.remove(DEVS, msg.sender);
  }

  /// @dev Classic "EIP-173" but for onlyDev()
  /// @param newDeveloper: addres of new pending Developer role
  function transferDeveloper(
    address newDeveloper
  ) external
    onlyRole(DEVS) {
    contractRoles.add(DEVS, newDeveloper);
    contractRoles.setOwner(newDeveloper);
    contractRoles.remove(DEVS, msg.sender);
  }

  /// @dev This accepts the push-pull method of onlyDev()
  function acceptDeveloper()
    external
    onlyRole(PENDING_DEVS) {
    contractRoles.add(DEVS, msg.sender);
    contractRoles.setOwner(msg.sender);
    contractRoles.remove(PENDING_DEVS, msg.sender);
  }

  /// @dev This declines the push-pull method of onlyDev()
  function declineDeveloper()
    external
    onlyRole(PENDING_DEVS) {
    contractRoles.remove(PENDING_DEVS, msg.sender);
  }

  /// @dev This starts the push-pull method of onlyDev()
  /// @param newDeveloper: addres of new pending developer role
  function pushDeveloper(
    address newDeveloper
  ) external
    onlyRole(DEVS) {
    contractRoles.add(PENDING_DEVS, msg.sender);
  }

  //////////////////////////////////////////
  /// [Not an EIP]: Contract Roles Standard
  //////////////////////////////////////////

  /// @dev Returns `true` if `account` has been granted `role`.
  /// @param role: Bytes4 of a role
  /// @param account: Address to check
  /// @return bool true/false if account has role
  function hasRole(
    bytes4 role
  , address account
  ) external
    view
    returns (bool) {
    return contractRoles.has(role, account);
  }

  /// @dev Returns the admin role that controls a role
  /// @param role: Role to check
  /// @return admin role
  function getRoleAdmin(
    bytes4 role
  ) external
    view 
    returns (bytes4) {
    return ADMIN;
  }

  /// @dev Grants `role` to `account`
  /// @param role: Bytes4 of a role
  /// @param account: account to give role to
  function grantRole(
    bytes4 role
  , address account
  ) external
    onlyRole(role) {
    if (role == PENDING_DEVS || role == PENDING_OWNERS) {
      revert Unauthorized();
    } else {
      contractRoles.add(role, account);
    }
  }

  /// @dev Revokes `role` from `account`
  /// @param role: Bytes4 of a role
  /// @param account: account to revoke role from
  function revokeRole(
    bytes4 role
  , address account
  ) external
    onlyRole(role) {
    if (role == PENDING_DEVS || role == PENDING_OWNERS) {
      if (account == msg.sender) {
        contractRoles.remove(role, account);
      } else {
        revert Unauthorized();
      }
    } else {
      contractRoles.remove(role, account);
    }
  }

  /// @dev Renounces `role` from `account`
  /// @param role: Bytes4 of a role
  function renounceRole(
    bytes4 role
  ) external
    onlyRole(role) {
    contractRoles.remove(role, msg.sender);
  }

  ////////////////////////////////////////////////////////////////////////
  /// ERC-721 Non-Fungible Token Standard, optional enumeration extension
  /// @dev may be added, but not fully supported see ERC-165 below
  ////////////////////////////////////////////////////////////////////////

  /// @notice Count NFTs tracked by this contract
  /// @return A count of valid NFTs tracked by this contract, where each one of
  ///  them has an assigned and queryable owner not equal to the zero address
  function totalSupply()
    external
    view
    virtual
    override
    returns (uint256) {
    return token721.getSupply();
  }

  /// @notice Enumerate valid NFTs
  /// @notice Throws if `_index` >= `totalSupply()`.
  /// @param _index A counter less than `totalSupply()`
  /// @return The token identifier for the `_index`th NFT,
  ///  (sort order not specified)
  function tokenByIndex(
    uint256 _index
  ) external
    view
    virtual
    override
    returns (uint256) {
    revert Unauthorized();
  }

  /// @notice Enumerate NFTs assigned to an owner
  /// @notice Throws if `_index` >= `balanceOf(_owner)` or if
  ///  `_owner` is the zero address, representing invalid NFTs.
  /// @param _owner An address where we are interested in NFTs owned by them
  /// @param _index A counter less than `balanceOf(_owner)`
  /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
  ///   (sort order not specified)
  function tokenOfOwnerByIndex(
    address _owner
  , uint256 _index
  ) external
    view
    virtual
    override
    returns (uint256) {
    revert Unauthorized();
  }

  /////////////////////////////////////////////////
  /// ERC721 Metadata, optional metadata extension
  /////////////////////////////////////////////////

  /// @notice A descriptive name for a collection of NFTs in this contract
  function name()
    external
    view
    virtual
    override
    returns (string memory _name) {
    return token721.getName();
  }

  /// @notice An abbreviated name for NFTs in this contract
  function symbol()
    external
    view
    virtual
    override
    returns (string memory _symbol) {
    return token721.getSymbol();
  }

  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
  /// @notice Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  function tokenURI(
    uint256 _tokenId
  ) external
    view
    virtual
    override
    returns (string memory) {
    return token721.getTokenURI(_tokenId);
  }

  ////////////////////////////////////////
  /// ERC-721 Non-Fungible Token Standard
  ////////////////////////////////////////

  /// @notice Count all NFTs assigned to an owner
  /// @notice NFTs assigned to the zero address are considered invalid, and this
  ///  function throws for queries about the zero address.
  /// @param _owner An address for whom to query the balance
  /// @return The number of NFTs owned by `_owner`, possibly zero
  function balanceOf(
    address _owner
  ) external
    view
    virtual
    override
    returns (uint256) {
    return token721.getBalanceOf(_owner);
  }

  /// @notice Find the owner of an NFT
  /// @notice NFTs assigned to zero address are considered invalid, and queries
  ///  about them do throw.
  /// @param _tokenId The identifier for an NFT
  /// @return The address of the owner of the NFT
  function ownerOf(
    uint256 _tokenId
  ) external
    view
    virtual
    override
    returns (address) {
    return token721.getOwnerOf(_tokenId);
  }

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @notice Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  /// @param data Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  , bytes calldata data
  ) external
    virtual
    override {
    token721.doTransferFrom(_from, _to, _tokenId);
    safeHook(_from, _to, _tokenId, data);
  }

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @notice This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to "".
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  ) external
    virtual
    override {
    this.safeTransferFrom(_from, _to, _tokenId, "");
  }

  /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  /// @notice Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function transferFrom(
    address _from
  , address _to
  , uint256 _tokenId
  ) external
    virtual
    override {
    token721.doTransferFrom(_from, _to, _tokenId);
  }

  /// @notice Change or reaffirm the approved address for an NFT
  /// @notice The zero address indicates there is no approved address.
  ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @param _approved The new approved NFT controller
  /// @param _tokenId The NFT to approve
  function approve(
    address _approved
  , uint256 _tokenId
  ) external
    virtual
    override {
    token721.setApprove(_approved, _tokenId);
  }

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all of `msg.sender`'s assets
  /// @notice Emits the ApprovalForAll event. The contract MUST allow
  ///  multiple operators per owner.
  /// @param _operator Address to add to the set of authorized operators
  /// @param _approved True if the operator is approved, false to revoke approval
  function setApprovalForAll(
    address _operator
  , bool _approved
  ) external
    virtual
    override {
    token721.setApprovalForAll(_operator, _approved);
  }

  /// @notice Get the approved address for a single NFT
  /// @notice Throws if `_tokenId` is not a valid NFT.
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(
    uint256 _tokenId
  ) external
    view
    virtual
    override
    returns (address) {
    return token721.getApproved(_tokenId);
  }

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(
    address _owner
  , address _operator
  ) external
    view
    virtual
    override
    returns (bool) {
    return token721.isApprovedForAll(_owner, _operator);
  }

  ///////////////////////////////////////////////////////////////////
  /// ERC-721 Non-Fungible Token Standard, required wallet interface
  /// @dev This is to disable all safe transfers to this contract
  ///////////////////////////////////////////////////////////////////

  /// @notice Handle the receipt of an NFT
  /// @notice The ERC721 smart contract calls this function on the recipient
  ///  after a `transfer`. This function MAY throw to revert and reject the
  ///  transfer. Return of other than the magic value MUST result in the
  ///  transaction being reverted.
  ///  Note: the contract address is always the message sender.
  /// @param _operator The address which called `safeTransferFrom` function
  /// @param _from The address which previously owned the token
  /// @param _tokenId The NFT identifier which is being transferred
  /// @param _data Additional data with no specified format
  /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  ///  unless throwing
  function onERC721Received(
    address _operator
  , address _from
  , uint256 _tokenId
  , bytes calldata _data
  ) external
    virtual
    override
    returns(bytes4) {
    return bytes4(keccak256("I don't want your stinkin tokens"));
  }

  /////////////////////////////////////////////////////////////
  /// [Not an EIP] NFT Minting engine, interface (for UX/UI's)
  /////////////////////////////////////////////////////////////

  /// @dev will return Provenance hash of images
  /// @return string memory of the Images Hash (sha256)
  function RevealProvenanceImages()
    external
    view
    virtual
    override
    returns (string memory) {
    return nftEngine.showProvenanceImages();
  }

  /// @dev will return Provenance hash of metadata
  /// @return string memory of the Metadata Hash (sha256)
  function RevealProvenanceJSON()
    external
    view
    virtual
    override
    returns (string memory) {
    return nftEngine.showProvenanceJSON();
  }

  /// @dev will return starting number for mint
  /// @return uint of the start number
  function RevealStartID()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showStartID();
  }

  /// @dev will return status of Minter
  /// @return - bool of active or not
  function minterStatus()
    external
    view
    virtual
    override
    returns (bool) {
    return nftEngine.showStatus();
  }

  /// @dev will return minting fees
  /// @return - uint of mint costs in wei
  function minterFees()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showFees();
  }

  /// @dev will return maximum mint capacity
  /// @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showCapacity();
  }

  /// @dev will return maximum mint capacity
  /// @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showCurrentMinted();
  }

  /// @dev will return maximum "team minting" capacity
  /// @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showTeamMints();
  }

  /// @dev will return "team mints" count
  /// @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    virtual
    override
    returns (uint256) {
    return nftEngine.showCurrentTeam();
  }

  /////////////////////////////////////////////////////
  /// [Not an EIP] NFT Minting engine, admin interface
  /////////////////////////////////////////////////////

  /// @dev this will set the boolean for minter status
  /// @param toggle: bool for enabled or not
  function setStatus(
    bool toggle
  ) external
    virtual
    onlyDev()
    override {
    nftEngine.setStatus(toggle);
  }

  /// @dev this will set the minter fees
  /// @param number: uint for fees in wei.
  function setMintFees(
    uint number
  ) external
    virtual
    onlyDev()
    override {
    nftEngine.setFees(number);
  }

  /// @dev this will set the Provenance Hashes
  /// @param img Provenance Hash of images in sequence
  /// @param json Provenance Hash of metadata in sequence
  /// @notice This will set the start number as well, make sure to set MaxCap
  ///  also can be a hyperlink... sha3... ipfs.. whatever.
  function setProvenance(
    string memory img
  , string memory json
  ) external
    virtual
    onlyDev()
    override {
    nftEngine.setProvIMG(img);
    nftEngine.setProvJSON(json);
    nftEngine.provLock();
  }

  /// @dev this will set the mint engine
  /// @param mintingCap uint for publicMint() capacity of this chain
  /// @param teamMints uint for maximum teamMints() capacity on this chain
  function setEngine(
    uint mintingCap
  , uint teamMints
  ) external
    virtual
    onlyDev()
    override {
    nftEngine.setMaxCap(mintingCap);
    nftEngine.setMaxTeam(teamMints);
    nftEngine.setStartNumber();
  }

  /////////////////////////////////////////////////////////////
  /// [Not an EIP]  List interface, for address access control
  /////////////////////////////////////////////////////////////

  /// @dev will return user status on Access
  /// @return - bool if Access is enabled or not
  /// @param myAddress - any user account address, EOA or contract
  function myListStatus(
    address myAddress
  ) external
    view
    virtual
    override
    returns (bool) {
    return allowed.onList(myAddress);
  }

  /// @dev will return status of Access
  /// @return - bool if Access is enabled or not
  function listStatus()
    external
    view
    virtual
    override
    returns (bool) {
    return allowed.status();
  }

  /////////////////////////////////////////////////////////////////////////////
  /// [Not an EIP] Time Cop, interface for a time based mechanism for solidity
  /////////////////////////////////////////////////////////////////////////////

  /// @dev function (getter) for epoch start and end for epoch
  /// @param epoch: uint256 of what epoch you want to return
  /// @return unix.timestamp for start of epoch (seconds)
  /// @return unix.timestamp for end of epoch (seconds)
  function getTimes(
    uint256 epoch
  ) external
    view
    virtual
    override
    returns (uint256, uint256) {
    (uint256 start, uint256 end) = times.getTimes(epoch);
    return (start, end);
  }

  /// @dev function (getter) for current epoch
  /// @return uint256 of current epoch's number
  function getEpoch()
    external
    view
    virtual
    override
    returns (uint256) {
    return times.getCurrentEpoch();
  }

  /// @dev function (state storage) will set an epoch and push to Epoch[]
  /// @notice this should be done in order, V2 will have an organizer?
  /// @param start: start time of this epoch in unix.timestamp (seconds)
  /// @param duration: length in seconds of the epoch
  function setEpoch(
    uint256 start
  , uint256 duration
  ) external
    virtual
    onlyDev()
    override {
    times.setEpoch(start, start + duration);
  }

  /// @dev function (state storage) will advance current epoch by 1
  function nextEpoch()
    external
    virtual
    onlyDev()
    override {
    times.advanceEpoch();
  }

  /////////////////////////////////////////////////
  /// [Not an EIP] List interface, admin extension
  /////////////////////////////////////////////////

  /// @dev adding functions to List
  /// @param newAddresses - array of addresses to add
  function addBatchAddresses(
    address[] memory newAddresses
  ) external
    virtual
    onlyDev()
    override {
    uint len = newAddresses.length;
    for (uint x = 0; x < len;) {
      allowed.add(newAddresses[x]);
      unchecked { ++x; }
    }
  }

  /// @dev adding functions to List
  /// @param newAddress - address to add
  function addAddresss(
    address newAddress
  ) external
    virtual
    onlyDev()
    override {
    allowed.add(newAddress);
  }

  /// @dev removing functions to List
  /// @param newAddresses - array of addresses to remove
  function removeBatchAddresses(
    address[] memory newAddresses
  ) external
    virtual
    onlyDev()
    override {
    uint len = newAddresses.length;
    for (uint x = 0; x < len;) {
      allowed.remove(newAddresses[x]);
      unchecked { ++x; }
    }
  }
    
  /// @dev removing functions to List
  /// @param newAddress - address to remove
  function removeAddress(
    address newAddress
  ) external
    virtual
    onlyDev()
    override {
    allowed.remove(newAddress);
  }

  /// @dev enables the List
  function enableList()
    external
    virtual
    onlyDev()
    override {
    allowed.enable();
  }

  /// @dev disables the List
  function disableList()
    external
    virtual
    onlyDev()
    override {
    allowed.disable();
  }

  /////////////////////////////////////////////////
  /// [Not an EIP] OpenSea Contract-level metadata
  /////////////////////////////////////////////////

  /// @dev function (getter) returns ContractURI for OpenSea
  /// @return string private thisContractURI on Max721Storage
  /// @notice see metadata schema on IContractURIAdmin.sol
  function contractURI()
    external
    view
    virtual
    override
    returns (string memory) {
    return thisContractURI;
  }

  //////////////////////////////////////////////////////////////////
  /// [Not an EIP] OpenSea Contract-level metadata, admin extension
  //////////////////////////////////////////////////////////////////

  /// @dev function (state storage) this sets thisContractURI
  /// @param URI: string to be stored in thisContractURI
  /// @notice This URI should return data of the following format:
  ///
  ///         {
  ///           "name": Project's name,
  ///           "description": Project's Description,
  ///           "image": pfp for project,
  ///           "external_link": web url,
  ///           "seller_fee_basis_points": 100 -> Indicates a 1% seller fee.
  ///           "fee_recipient": checksum address
  ///         }
  function setContractURI(
    string memory URI
  ) external
    virtual 
    onlyDev()
    override {
    string memory old = thisContractURI;
    thisContractURI = URI;
    emit ContractURIChange(old, thisContractURI);
  }

  ////////////////////////////////////////////////////////////////
  /// [Not an EIP] Payment Splitter, interface for ether payments
  ////////////////////////////////////////////////////////////////

  /// @dev returns total shares
  /// @return uint256 of all shares on contract
  function totalShares()
    external
    view
    virtual
    override
    returns (uint256) {
    return splitter.getTotalShares();
  }

  /// @dev returns shares of an address
  /// @param payee address of payee to return
  /// @return mapping(address => uint) of _shares
  function shares(
    address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.payeeShares(payee);
  }

  /// @dev returns total releases in "eth"
  /// @return uint256 of all "eth" released in wei
  function totalReleased()
    external
    view
    virtual
    override
    returns (uint256) {
    return splitter.getTotalReleased();
  }

  /// @dev returns released "eth" of an payee
  /// @param payee address of payee to look up
  /// @return mapping(address => uint) of _released
  function released(
    address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.payeeReleased(payee);
  }

  /// @dev returns amount of "eth" that can be released to payee
  /// @param payee address of payee to look up
  /// @return uint in wei of "eth" to release
  function releasable(
    address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    uint totalReceived
      = address(this).balance
      + this.totalReleased();
    return 
      totalReceived
    * this.shares(payee)
    / this.totalShares()
    - this.released(payee);
  }

  /// @dev returns index number of payee
  /// @param payee number of index
  /// @return address at _payees[index]
  function payeeIndex(
    address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.payeeIndex(payee);
  }

  /// @dev this returns the array of payees[]
  /// @return address[] payees
  function payees()
    external
    view
    virtual
    override
    returns (address[] memory) {
    return splitter.getPayees();
  }

  /// @dev this claims all "eth" on contract for msg.sender
  function claim()
    external
    virtual
    override {
    if (this.shares(msg.sender) == 0) {
      revert Unauthorized();
    }
    uint256 payment = this.releasable(msg.sender);
    if (payment == 0) {
      revert Unauthorized();
    }
    splitter.processPayment(msg.sender, payment);
    Address.sendValue(payable(msg.sender), payment);
  }

  /// @dev This pays all payees
  function payClaims()
    external
    virtual
    override {
    address[] memory toPay = splitter.getPayees();
    uint256 len = toPay.length;
    for (uint x = 0 ; x < len ;) {
      uint256 payment = this.releasable(toPay[x]);
      splitter.processPayment(toPay[x], payment);
      Address.sendValue(payable(toPay[x]), payment);
      unchecked { ++x; }
    }
  }

  /// @dev This adds a payee
  /// @param payee Address of payee
  /// @param _shares Shares to send user
  function addPayee(
    address payee
  , uint256 _shares
  ) external
    virtual
    onlyDev()
    override {
    splitter.addPayee(payee, _shares);
  }

  /// @dev This removes a payee
  /// @param payee Address of payee to remove
  /// @notice use payPayees() prior to use if anything is on the contract
  function removePayee(
    address payee
  ) external
    virtual
    onlyDev()
    override {
    splitter.removePayee(payee);
  }

  /// @dev This removes all payees
  /// @notice use payPayees() prior to use if anything is on the contract
  function clearPayees()
    external
    virtual
    onlyDev()
    override {
    splitter.clearPayees();
  }

  //////////////////////////////////////////////////////////////////////////
  /// [Not an EIP] Payment Splitter, interface extension for erc20 payments
  //////////////////////////////////////////////////////////////////////////

  /// @dev returns total releases in ERC20
  /// @param _token ERC20 Contract Address
  /// @return uint256 of all ERC20 released in address.decimals()
  function totalReleased(
    address _token
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.getTotalReleased(_token);
  }

  /// @dev returns released ERC20 of an payee
  /// @param _token ERC20 Contract Address
  /// @param payee address of payee to look up
  /// @return mapping(address => uint) of _released
  function released(
    address _token
  , address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.payeeReleased(_token, payee);
  }

  /// @dev returns amount of ERC20 that can be released to payee
  /// @param _token ERC20 Contract Address
  /// @param payee address of payee to look up
  /// @return uint in address.decimals() of ERC20 to release
  function releasable(
    address _token
  , address payee
  ) external
    view
    virtual
    override
    returns (uint256) {
    uint totalReceived = 
      IERC20(_token).balanceOf(address(this))
    + splitter.getTotalReleased(_token);
    return 
      totalReceived
    * splitter.payeeShares(payee)
    / splitter.getTotalShares()
    - splitter.payeeReleased(_token, payee);
  }

  /// @dev returns index number of token
  /// @param ca address of erc20 smart contract
  /// @return address at token[index]
  function token(
    address ca
  ) external
    view
    virtual
    override
    returns (uint256) {
    return splitter.tokenIndex(ca);
  }

  /// @dev this returns the array of tokens[]
  /// @return address[] tokens
  function tokens()
    external
    view
    virtual
    override
    returns (address[] memory) {
    return splitter.getTokens();
  }

  /// @dev this claims all ERC20 on contract for msg.sender
  /// @param _token ERC20 Contract Address
  function claim(
    address _token
  ) external
    virtual
    override {
    if (this.shares(msg.sender) == 0) {
      revert Unauthorized();
    }
    uint256 payment = this.releasable(_token, msg.sender);
    if (payment == 0) {
      revert Unauthorized();
    }
    splitter.processPayment(msg.sender, payment, _token);
    Safe20.safeTransfer(IERC20(_token), msg.sender, payment);
  }

  /// @dev This pays all payees
  /// @param _token ERC20 Contract Address
  function payClaims(
    address _token
  ) external
    virtual
    override {
    address[] memory toPay = splitter.getPayees();
    uint256 len = toPay.length;
    for (uint x = 0 ; x < len ;) {
      uint256 payment = this.releasable(_token, toPay[x]);
      splitter.processPayment(toPay[x], payment, _token);
      Safe20.safeTransfer(IERC20(_token), toPay[x], payment);
      unchecked { ++x; }
    }
  }

  /// @dev this claims all "eth" and ERC20's from address[] tokens
  ///       on contract for msg.sender
  function claimAll()
    external
    virtual
    override {
    this.claim();
    address[] memory allTokens = this.tokens();
    uint len = allTokens.length;
    for (uint x = 0; x < len;) {
      this.claim(allTokens[x]);
      unchecked { ++x; }
    }
  }

  /// @dev This pays all "eth" and ERC20's from address[] tokens
  ///       on contract for all on address[] payees
  function payAll()
    external
    virtual
    override {
    this.payClaims();
    address[] memory allTokens = this.tokens();
    uint len = allTokens.length;
    for (uint x = 0 ; x < len ;) {
      this.payClaims(allTokens[x]);
      unchecked { ++x; }
    }
  }

  /// @dev This adds a token on tokens[]
  /// @param _token ERC20 Contract Address to add
  function addToken(
    address _token
  ) external
    virtual
    onlyDev()
    override {
    splitter.addToken(_token);
  }

  /// @dev This removes a token on tokens[]
  /// @param _token ERC20 Contract Address to remove
  function removeToken(
    address _token
  ) external
    virtual
    onlyDev()
    override {
    splitter.removeToken(_token);
  }

  /// @dev This removes all tokens on tokens[]
  function clearTokens()
    external
    virtual
    onlyDev()
    override {
    splitter.clearTokens();
  }

  //////////////////////////////////////////
  /// EIP-165: Standard Interface Detection
  //////////////////////////////////////////

  /// @dev Query if a contract implements an interface
  /// @param interfaceID The interface identifier, as specified in ERC-165
  /// @notice Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(
    bytes4 interfaceID
  ) external
    view
    virtual
    override
    returns (bool) {
    return (
      interfaceID == type(IERC173).interfaceId  ||
      interfaceID == type(IMAX173).interfaceId  ||
      interfaceID == type(IMAXDEV).interfaceId  ||
      interfaceID == type(IRoles).interfaceId  ||
      interfaceID == type(IERC721).interfaceId  ||
      interfaceID == type(IERC721Metadata).interfaceId  ||
      interfaceID == type(IContractURI).interfaceId  ||
      interfaceID == type(IContractURIAdmin).interfaceId  ||
      interfaceID == type(IPsuedoRand).interfaceId  ||
      interfaceID == type(IPsuedoRandAdmin).interfaceId  ||
      interfaceID == type(IList).interfaceId  ||
      interfaceID == type(IListAdmin).interfaceId  ||
      interfaceID == type(ITimeCop).interfaceId ||
      interfaceID == type(ISplitter).interfaceId ||
      interfaceID == type(ISplitterERC20).interfaceId
    );
  }
}