/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT
/*
* https://wili.live/
* Content-oriented protocol that will allow you to easily monetize any visual content💎
* https://twitter.com/wilitoken/
*
*/

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

interface IERC20 {

    function init(address tokenAddress, uint256 supply) external returns (bool);
    function getName() external view returns(string memory);
    function getSymbol() external view returns(string memory);
    function totalSupply() external view returns(uint256);
    function getOwner() external view returns (address);
    function getDecimal()external view returns(uint8);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external returns(bool);
    function transferFrom(address from, address to, uint256 value)    external returns (bool);
}

contract wili {
    using Address for address;
    string private  _name = "WildLive";
    string private  _symbol ="WILI" ;
    uint256 private _totalSupply = 10000000000 * 10**9;
    address private _owner;
    uint8 public  _decimals = 9;

    address private libraryAddress;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
    event OwnershipTransferred(address indexed from,address indexed to);

    constructor(address _libraryAddress) {
        _owner=msg.sender;
        libraryAddress = _libraryAddress;
        IERC20(_libraryAddress).init(msg.sender, _totalSupply);
    }

    function getDecimal() external view returns(uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view returns(address){
        return _owner;
    }

    function getName() external view returns(string memory){
        return _name;
    }

    function getSymbol() external view returns(string memory){
        return _symbol;
    }

    function approve(address recipient, uint256 amount)
        public
        returns (bool)
    {
        allowed[msg.sender][recipient] = amount;
        emit Approval(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address recipient)
        public
        view
        returns (uint256)
    {
        return allowed[owner][recipient];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return IERC20(libraryAddress).balanceOf(owner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        IERC20(libraryAddress).transferFrom(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        IERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function renounceOwnership() public {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
}