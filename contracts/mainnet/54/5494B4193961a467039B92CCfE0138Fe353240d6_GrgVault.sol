// SPDX-License-Identifier: Apache 2.0

/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.8.17;

import "../utils/0xUtils/Authorizable.sol";
import "../utils/0xUtils/IAssetProxy.sol";
import "../utils/0xUtils/IAssetData.sol";
import "../utils/0xUtils/IERC20Token.sol";
import "./interfaces/IGrgVault.sol";

contract GrgVault is Authorizable, IGrgVault {
    // Address of staking proxy contract
    address public stakingProxy;

    // True iff vault has been set to Catastrophic Failure Mode
    bool public isInCatastrophicFailure;

    // Mapping from staker to GRG balance
    mapping(address => uint256) internal _balances;

    // Grg Asset Proxy
    IAssetProxy public grgAssetProxy;

    // Grg Token
    IERC20Token internal _grgToken;

    // Asset data for the ERC20 Proxy
    bytes internal _grgAssetData;

    /// @dev Only stakingProxy can call this function.
    modifier onlyStakingProxy() {
        _assertSenderIsStakingProxy();
        _;
    }

    /// @dev Function can only be called in catastrophic failure mode.
    modifier onlyInCatastrophicFailure() {
        _assertInCatastrophicFailure();
        _;
    }

    /// @dev Function can only be called not in catastropic failure mode
    modifier onlyNotInCatastrophicFailure() {
        _assertNotInCatastrophicFailure();
        _;
    }

    /// @dev Constructor.
    /// @param grgProxyAddress Address of the RigoBlock Grg Proxy.
    /// @param grgTokenAddress Address of the Grg Token.
    /// @param newOwner Address of the Grg vault owner.
    constructor(
        address grgProxyAddress,
        address grgTokenAddress,
        address newOwner
    ) Authorizable(newOwner) {
        grgAssetProxy = IAssetProxy(grgProxyAddress);
        _grgToken = IERC20Token(grgTokenAddress);
        _grgAssetData = abi.encodeWithSelector(IAssetData(address(0)).ERC20Token.selector, grgTokenAddress);
    }

    /// @dev Sets the address of the StakingProxy contract.
    /// Note that only the contract owner can call this function.
    /// @param stakingProxyAddress Address of Staking proxy contract.
    function setStakingProxy(address stakingProxyAddress) external override onlyAuthorized {
        stakingProxy = stakingProxyAddress;
        emit StakingProxySet(stakingProxyAddress);
    }

    /// @dev Vault enters into Catastrophic Failure Mode.
    /// *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// Note that only the contract owner can call this function.
    function enterCatastrophicFailure() external override onlyAuthorized onlyNotInCatastrophicFailure {
        isInCatastrophicFailure = true;
        emit InCatastrophicFailureMode(msg.sender);
    }

    /// @dev Sets the Grg proxy.
    /// Note that only an authorized address can call this function.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param grgProxyAddress Address of the RigoBlock Grg Proxy.
    function setGrgProxy(address grgProxyAddress) external override onlyAuthorized onlyNotInCatastrophicFailure {
        grgAssetProxy = IAssetProxy(grgProxyAddress);
        emit GrgProxySet(grgProxyAddress);
    }

    /// @dev Deposit an `amount` of Grg Tokens from `staker` into the vault.
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to deposit.
    function depositFrom(address staker, uint256 amount)
        external
        override
        onlyStakingProxy
        onlyNotInCatastrophicFailure
    {
        // update balance
        _balances[staker] += amount;

        // notify
        emit Deposit(staker, amount);

        // deposit GRG from staker
        grgAssetProxy.transferFrom(_grgAssetData, staker, address(this), amount);
    }

    /// @dev Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// Note that only the Staking contract can call this.
    /// Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to withdraw.
    function withdrawFrom(address staker, uint256 amount)
        external
        override
        onlyStakingProxy
        onlyNotInCatastrophicFailure
    {
        _withdrawFrom(staker, amount);
    }

    /// @dev Withdraw ALL Grg Tokens to `staker` from the vault.
    /// Note that this can only be called when *in* Catastrophic Failure mode.
    /// @param staker of Grg Tokens.
    function withdrawAllFrom(address staker) external override onlyInCatastrophicFailure returns (uint256) {
        // get total balance
        uint256 totalBalance = _balances[staker];

        // withdraw GRG to staker
        _withdrawFrom(staker, totalBalance);
        return totalBalance;
    }

    /// @dev Returns the balance in Grg Tokens of the `staker`
    /// @return Balance in Grg.
    function balanceOf(address staker) external view override returns (uint256) {
        return _balances[staker];
    }

    /// @dev Returns the entire balance of Grg tokens in the vault.
    function balanceOfGrgVault() external view override returns (uint256) {
        return _grgToken.balanceOf(address(this));
    }

    /// @dev Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// @param staker of Grg Tokens.
    /// @param amount of Grg Tokens to withdraw.
    function _withdrawFrom(address staker, uint256 amount) internal {
        // update balance
        // note that this call will revert if trying to withdraw more
        // than the current balance
        _balances[staker] -= amount;

        // notify
        emit Withdraw(staker, amount);

        // withdraw GRG to staker
        _grgToken.transfer(staker, amount);
    }

    /// @dev Asserts that sender is stakingProxy contract.
    function _assertSenderIsStakingProxy() private view {
        require(msg.sender == stakingProxy, "GRG_VAULT_ONLY_CALLABLE_BY_STAKING_PROXY_ERROR");
    }

    /// @dev Asserts that vault is in catastrophic failure mode.
    function _assertInCatastrophicFailure() private view {
        require(isInCatastrophicFailure, "GRG_VAULT_NOT_IN_CATASTROPHIC_FAILURE_ERROR");
    }

    /// @dev Asserts that vault is not in catastrophic failure mode.
    function _assertNotInCatastrophicFailure() private view {
        require(!isInCatastrophicFailure, "GRG_VAULT_IN_CATASTROPHIC_FAILURE_ERROR");
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.9.0;

import "./interfaces/IAuthorizable.sol";
import "./Ownable.sol";

// solhint-disable no-empty-blocks
// TODO: check if should use OwnedUninitialized and remove duplicate contract
abstract contract Authorizable is Ownable, IAuthorizable {
    /// @dev Only authorized addresses can invoke functions with this modifier.
    modifier onlyAuthorized() {
        _assertSenderIsAuthorized();
        _;
    }

    /// @dev Whether an address is authorized to call privileged functions.
    /// @dev 0 Address to query.
    /// @return 0 Whether the address is authorized.
    mapping(address => bool) public authorized;
    /// @dev Whether an adderss is authorized to call privileged functions.
    /// @dev 0 Index of authorized address.
    /// @return 0 Authorized address.
    address[] public authorities;

    /// @dev Initializes the `owner` address.
    constructor(address newOwner) Ownable(newOwner) {}

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target) external override onlyOwner {
        _addAuthorizedAddress(target);
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target) external override onlyOwner {
        require(authorized[target], "TARGET_NOT_AUTHORIZED");
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(address target, uint256 index) external override onlyOwner {
        _removeAuthorizedAddressAtIndex(target, index);
    }

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses() external view override returns (address[] memory) {
        return authorities;
    }

    /// @dev Reverts if msg.sender is not authorized.
    function _assertSenderIsAuthorized() internal view {
        require(authorized[msg.sender], "AUTHORIZABLE_SENDER_NOT_AUTHORIZED_ERROR");
    }

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function _addAuthorizedAddress(address target) internal {
        // Ensure that the target is not the zero address.
        require(target != address(0), "AUTHORIZABLE_NULL_ADDRESS_ERROR");

        // Ensure that the target is not already authorized.
        require(!authorized[target], "AUTHORIZABLE_ALREADY_AUTHORIZED_ERROR");

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    /// @dev Removes authorization of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function _removeAuthorizedAddressAtIndex(address target, uint256 index) internal {
        require(authorized[target], "AUTHORIZABLE_ADDRESS_NOT_AUTHORIZED_ERROR");
        require(index < authorities.length, "AUTHORIZABLE_INDEX_OUT_OF_BOUNDS_ERROR");
        require(authorities[index] == target, "AUTHORIZABLE_ADDRESS_MISMATCH_ERROR");

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.4 <0.9.0;

abstract contract IAssetProxy {
    /// @dev Transfers assets. Either succeeds or throws.
    /// @param assetData Byte array encoded for the respective asset proxy.
    /// @param from Address to transfer asset from.
    /// @param to Address to transfer asset to.
    /// @param amount Amount of asset to transfer.
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    ) external virtual;

    /// @dev Gets the proxy id associated with the proxy address.
    /// @return Proxy id.
    function getProxyId() external pure virtual returns (bytes4);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

// solhint-disable
pragma solidity >=0.5.4 <0.9.0;
pragma experimental ABIEncoderV2;

// @dev Interface of the asset proxy's assetData.
// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.
interface IAssetData {
    /// @dev Function signature for encoding ERC20 assetData.
    /// @param tokenAddress Address of ERC20Token contract.
    function ERC20Token(address tokenAddress) external;

    /// @dev Function signature for encoding ERC721 assetData.
    /// @param tokenAddress Address of ERC721 token contract.
    /// @param tokenId Id of ERC721 token to be transferred.
    function ERC721Token(address tokenAddress, uint256 tokenId) external;

    /// @dev Function signature for encoding ERC1155 assetData.
    /// @param tokenAddress Address of ERC1155 token contract.
    /// @param tokenIds Array of ids of tokens to be transferred.
    /// @param values Array of values that correspond to each token id to be transferred.
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    /// @param callbackData Extra data to be passed to receiver's `onERC1155Received` callback function.
    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    ) external;

    /// @dev Function signature for encoding MultiAsset assetData.
    /// @param values Array of amounts that correspond to each asset to be transferred.
    ///        Note that each value will be multiplied by the amount being filled in the order before transferring.
    /// @param nestedAssetData Array of assetData fields that will be be dispatched to their correspnding AssetProxy contract.
    function MultiAsset(uint256[] calldata values, bytes[] calldata nestedAssetData) external;

    /// @dev Function signature for encoding StaticCall assetData.
    /// @param staticCallTargetAddress Address that will execute the staticcall.
    /// @param staticCallData Data that will be executed via staticcall on the staticCallTargetAddress.
    /// @param expectedReturnDataHash Keccak-256 hash of the expected staticcall return data.
    function StaticCall(
        address staticCallTargetAddress,
        bytes calldata staticCallData,
        bytes32 expectedReturnDataHash
    ) external;

    /// @dev Function signature for encoding ERC20Bridge assetData.
    /// @param tokenAddress Address of token to transfer.
    /// @param bridgeAddress Address of the bridge contract.
    /// @param bridgeData Arbitrary data to be passed to the bridge contract.
    function ERC20Bridge(
        address tokenAddress,
        address bridgeAddress,
        bytes calldata bridgeData
    ) external;
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.5.9 <0.9.0;

abstract contract IERC20Token {
    // solhint-disable no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address _to, uint256 _value) external virtual returns (bool);

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external virtual returns (bool);

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address _spender, uint256 _value) external virtual returns (bool);

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply() external view virtual returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address _owner) external view virtual returns (uint256);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view virtual returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
/*

  Original work Copyright 2019 ZeroEx Intl.
  Modified work Copyright 2020-2022 Rigo Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity >=0.8.0 <0.9.0;

interface IGrgVault {
    /// @notice Emmitted whenever a StakingProxy is set in a vault.
    /// @param stakingProxyAddress Address of the staking proxy contract.
    event StakingProxySet(address stakingProxyAddress);

    /// @notice Emitted when the Staking contract is put into Catastrophic Failure Mode
    /// @param sender Address of sender (`msg.sender`)
    event InCatastrophicFailureMode(address sender);

    /// @notice Emitted when Grg Tokens are deposited into the vault.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens deposited.
    event Deposit(address indexed staker, uint256 amount);

    /// @notice Emitted when Grg Tokens are withdrawn from the vault.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens withdrawn.
    event Withdraw(address indexed staker, uint256 amount);

    /// @notice Emitted whenever the Grg AssetProxy is set.
    /// @param grgProxyAddress Address of the Grg transfer proxy.
    event GrgProxySet(address grgProxyAddress);

    /// @notice Sets the address of the StakingProxy contract.
    /// @dev Note that only the contract staker can call this function.
    /// @param stakingProxyAddress Address of Staking proxy contract.
    function setStakingProxy(address stakingProxyAddress) external;

    /// @notice Vault enters into Catastrophic Failure Mode.
    /// @dev *** WARNING - ONCE IN CATOSTROPHIC FAILURE MODE, YOU CAN NEVER GO BACK! ***
    /// @dev Note that only the contract staker can call this function.
    function enterCatastrophicFailure() external;

    /// @notice Sets the Grg proxy.
    /// @dev Note that only the contract staker can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param grgProxyAddress Address of the RigoBlock Grg Proxy.
    function setGrgProxy(address grgProxyAddress) external;

    /// @notice Deposit an `amount` of Grg Tokens from `staker` into the vault.
    /// @dev Note that only the Staking contract can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens to deposit.
    function depositFrom(address staker, uint256 amount) external;

    /// @notice Withdraw an `amount` of Grg Tokens to `staker` from the vault.
    /// @dev Note that only the Staking contract can call this.
    /// @dev Note that this can only be called when *not* in Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    /// @param amount of Grg Tokens to withdraw.
    function withdrawFrom(address staker, uint256 amount) external;

    /// @notice Withdraw ALL Grg Tokens to `staker` from the vault.
    /// @dev Note that this can only be called when *in* Catastrophic Failure mode.
    /// @param staker Address of the Grg staker.
    function withdrawAllFrom(address staker) external returns (uint256);

    /// @notice Returns the balance in Grg Tokens of the `staker`
    /// @param staker Address of the Grg staker.
    /// @return Balance in Grg.
    function balanceOf(address staker) external view returns (uint256);

    /// @notice Returns the entire balance of Grg tokens in the vault.
    /// @return Balance in Grg.
    function balanceOfGrgVault() external view returns (uint256);
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

abstract contract IAuthorizable {
    /// @dev Emitted when a new address is authorized.
    /// @param target Address of the authorized address.
    /// @param caller Address of the address that authorized the target.
    event AuthorizedAddressAdded(address indexed target, address indexed caller);

    /// @dev Emitted when a currently authorized address is unauthorized.
    /// @param target Address of the authorized address.
    /// @param caller Address of the address that authorized the target.
    event AuthorizedAddressRemoved(address indexed target, address indexed caller);

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target) external virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target) external virtual;

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    /// @param index Index of target in authorities array.
    function removeAuthorizedAddressAtIndex(address target, uint256 index) external virtual;

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses() external view virtual returns (address[] memory);
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

import "./interfaces/IOwnable.sol";

abstract contract Ownable is IOwnable {
    /// @dev The owner of this contract.
    /// @return 0 The owner address.
    address public owner;

    constructor(address newOwner) {
        owner = newOwner;
    }

    modifier onlyOwner() {
        _assertSenderIsOwner();
        _;
    }

    /// @dev Change the owner of this contract.
    /// @param newOwner New owner address.
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "INPUT_ADDRESS_NULL_ERROR");
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function _assertSenderIsOwner() internal view {
        require(msg.sender == owner, "CALLER_NOT_OWNER_ERROR");
    }
}

// SPDX-License-Identifier: Apache 2.0
/*
  Copyright 2019 ZeroEx Intl.
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity >=0.5.9 <0.9.0;

abstract contract IOwnable {
    /// @dev Emitted by Ownable when ownership is transferred.
    /// @param previousOwner The previous owner of the contract.
    /// @param newOwner The new owner of the contract.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Transfers ownership of the contract to a new address.
    /// @param newOwner The address that will become the owner.
    function transferOwnership(address newOwner) public virtual;
}