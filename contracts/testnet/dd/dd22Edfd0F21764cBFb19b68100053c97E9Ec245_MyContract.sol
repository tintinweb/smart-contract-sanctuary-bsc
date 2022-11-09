/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library AddressUpgradeable{
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Initializable{
    /**
     * @dev Indicates that the contract has been initialized.
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    event Initialized(uint8 version);

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }


    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


interface IERC20Upgradeable {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract MyContract is Initializable{

    address public owner;
    uint256 public fee;
    address public receiver;
    uint256 public feeamounts;
    mapping(address => bool) public authorizedusers;
    IERC20Upgradeable public tokenaddress; // HODL the token i set to use the tool for free
    uint256 public quantity; // must HODL atleast X tokens set

    bool private initialized; //To make sure that contract must be initialized only once as it is upgradeable
    uint256 public amountForLocking;  //Amount to lock for specific time 
    uint256 public expiry; // Cliff time to claim the locked amount

    bool public locked = false;  //Is locked
    bool public claimed = false; //Is claimed

    struct vesterReceiver {//who gets the vested token
        bool locked;  //Is locked
        bool claimed; //Is claimed
    }

    mapping (address=>vesterReceiver) vesterAddress; //who gets the vested token


    constructor() {
        _disableInitializers();
        }

    function initialize() public onlyInitializing {
        owner = msg.sender;
    }



    function BNBmultisender(address[] memory recipients, uint256[] memory values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity ) {
            require (msg.value >= fee, "You have to pay fee to use  Multi bulk function"); //TAKE FEE IF NOT AUTHORIZED
            feeamounts += fee;
            payable(receiver).transfer(fee);
        }

        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
    
        uint256 balance = address(this).balance;
    
        if (balance > 0)
            payable(msg.sender).transfer(balance);
    }

    function TOKENmultisender(IERC20Upgradeable token, address[] memory recipients, uint256[] memory values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity) {
            require (msg.value >= fee, "You have to pay fee to use  Token Multi bulk function");
            feeamounts += fee;
            payable(receiver).transfer(fee);
        }

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    // Modifier to check msg.sender is owner.
    modifier onlyOwner {
      require(msg.sender == owner, "Only Onwer can access this function");
      _;
    }

    // setfeetouse  --- function 1
    function setfeetouse (uint256 newfee, address _receiver) onlyOwner external {
        fee = newfee;
        receiver = _receiver;
    }

    // Simple BNB withdraw function  --- function 1

    function withdraw() onlyOwner external {
        if(feeamounts > 0)
            payable(msg.sender).transfer(feeamounts);
    }

    // authorizetouse ---- function 2
    function authorizetouse(address _addr) onlyOwner external {
        authorizedusers[_addr] = true;
    }

    // set authorised addresses  (owner can set address true or false ) 
    function setauthor(address _addr, bool _bool) onlyOwner external {
        if(authorizedusers[_addr]) {
            authorizedusers[_addr] = _bool;
        }
    }

    // Set Token Address and Quantity
    function SetTokenToholdAndQuantity (IERC20Upgradeable token, uint256 _amount) onlyOwner external {
        tokenaddress = token;
        quantity = _amount;
    }

    //Lock function
    function lock(address _from, address _receiver, uint256 _amount, uint256 _expiry) public {
        vesterAddress[_receiver];
        require(!vesterAddress[_receiver].locked, "We have already locked tokens.");
        tokenaddress.transferFrom(_from, address(this), _amount);
        quantity = _amount;
        expiry = _expiry;
        vesterAddress[_receiver].locked = true;
    }

    //vesting with Cliff(period)
    function vesting() public {
        require(vesterAddress[msg.sender].locked, "Funds have not been locked");
        require(block.timestamp > expiry, "Tokens have not been unlocked");
        require(!vesterAddress[msg.sender].claimed, "Tokens have already been claimed");
        tokenaddress.transfer(msg.sender, quantity);
        vesterAddress[msg.sender].claimed = true;
    }


}