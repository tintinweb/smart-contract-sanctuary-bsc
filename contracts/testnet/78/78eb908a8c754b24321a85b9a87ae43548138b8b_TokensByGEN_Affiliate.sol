/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: Unlicensed 
// "Unlicensed" is NOT Open Source 
// This contract can not be used/forked without permission 



/*

Affiliate Holder Token for TokensByGEN.com

*/


pragma solidity 0.8.10;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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




contract TokensByGEN_Affiliate { 

    using Address   for address;

    constructor () {
    _owner = payable(0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5);
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "Caller must be owner");
        _;
    }

    // Balances
    mapping (address => uint256) private _tOwned;

    // Owner
    address payable public _owner;

    // Token info
    uint256 private constant _decimals = 0; 
    uint256 private _tTotal = 0; 
    string  private constant _name = "TokensByGen.com";
    string  private constant _symbol = "GEN_AFF";


    function owner() public view virtual returns (address) {
        return _owner;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }


    // Approve / Revoke Affiliate Status

    function Affiliate_APPROVE(address Affiliate, uint256 Level) external onlyOwner {
        _tOwned[Affiliate] = Level;
    }

    function Affiliate_APPROVE_BULK(address[] calldata Affiliates) external onlyOwner {
        for (uint i=0; i < Affiliates.length; i++) {
        _tOwned[Affiliates[i]] = 1;
        }
    }

    function Affiliate_REVOKE(address Affiliate) external onlyOwner {
        _tOwned[Affiliate] = 0;
    }


    // Purge BNB
    function Purge_BNB() public {
        uint256 BNB = address(this).balance;
        if(BNB > 0){
        _owner.transfer(BNB);
        }
    }

    // Purge Token
    function Purge_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external onlyOwner returns(bool _sent){
        // Can not purge the native token!
        require (random_Token_Address != address(this), "Can not remove native token, must be processed via SwapAndLiquify");
        if(percent_of_Tokens > 100){percent_of_Tokens = 100;}
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        _sent = IERC20(random_Token_Address).transfer(msg.sender, removeRandom);

    }

    // Allow contract to receive BNB 
    receive() external payable {}

}