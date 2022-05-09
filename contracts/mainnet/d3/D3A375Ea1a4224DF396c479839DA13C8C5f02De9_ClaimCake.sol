/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


interface IPlanetBoostedStrategyCake {
    struct UserInfo {
        uint256 shares;
        uint256 earnRewardDebt;
        uint256 pendingRewards;
    }
    function userInfo(address userAddress) external view returns (UserInfo memory);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function mint(address mintTo, uint256 amount) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory){
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory){
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory){
        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory){
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory){
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

library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal{
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor(){
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract ClaimCake is ReentrancyGuard{
    
    using SafeERC20 for IERC20;

    bool public isPaused = false;

    address public owner;
    address public immutable sendBackCakeAddress; //gnosis safe address

    mapping(address => withdrawInfo) public userWithdrawInfo;

    IERC20 public cakeToken;
    IPlanetBoostedStrategyCake public immutable planetBoostedStrategyCake;

    struct withdrawInfo {
        bool withdrew;
        uint256 amountWithdrawn;
    }

    event userWithdrew(address userAddress, uint256 withdrawAmount);
    event ownerChanged(address newOwner);

    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _;
    }
    modifier active(){
        require(isPaused==false, "Contract is paused");
        _;
    }

    constructor(address _planetBoostedStrategyCakeAddress, address _owner, address _cakeTokenAddress, address _sendBackCakeAddress) ReentrancyGuard(){
        planetBoostedStrategyCake = IPlanetBoostedStrategyCake(_planetBoostedStrategyCakeAddress);
        owner = _owner;
        cakeToken = IERC20(_cakeTokenAddress);
        sendBackCakeAddress = _sendBackCakeAddress;
    }

    function withdrawUsersCake() external active nonReentrant returns (uint256 userShares) {
        
        require(!userWithdrawInfo[msg.sender].withdrew, "User shares already claimed");

        IPlanetBoostedStrategyCake.UserInfo memory userInfo = planetBoostedStrategyCake.userInfo(msg.sender);
        userShares = userInfo.shares;
        require(userShares > 0, "User share is 0");

        uint256 contractCakeBalance = cakeToken.balanceOf(address(this));
        require(contractCakeBalance >= userShares, "Withdraw amount > contract balance");

        userWithdrawInfo[msg.sender].withdrew = true;
        userWithdrawInfo[msg.sender].amountWithdrawn = userShares;
        
        cakeToken.safeTransfer(msg.sender, userShares);
        

        emit userWithdrew(msg.sender, userShares);

    }

    function pauseContract() external onlyOwner {
        require(isPaused==false, "contract is inactive");
        isPaused = true;
    }

    function unpauseContract() external onlyOwner {
        require(isPaused==true, "contract is active");
        isPaused = false;
    }
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner!=address(0), "Not a valid address");
        owner = _newOwner;
        emit ownerChanged(_newOwner);
    }

    function emergencySendBackCake() external onlyOwner{
        //only emergency usage incase we need to transfer funds to the Pancake Chefs

        uint256 contractCakeBalance = cakeToken.balanceOf(address(this));
        require(contractCakeBalance > 0, "No cakes left");
        cakeToken.safeTransfer(sendBackCakeAddress, contractCakeBalance);

    }

}