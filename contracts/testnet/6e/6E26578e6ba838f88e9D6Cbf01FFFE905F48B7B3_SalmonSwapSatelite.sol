/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity >=0.8.0 < 0.9.0;
// SPDX-License-Identifier: Unlicensed
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
 }
abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) private _team;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
        _team[_owner] = true;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function TeamMember(address TeamMember_) public view virtual returns (bool) {
        return _team[TeamMember_];
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyTeam() {
        require(_team[_msgSender()] == true, "Ownable: caller is not in the team");
        _;
    }
    function addTeamMember(address account) public onlyOwner {
        _team[account] = true;
     }
    function removeTeamMember(address account) public onlyOwner {
        _team[account] = false;
     }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
 }
interface SS {
    function sellbyExactTokens(address Contract_, uint tokens_) external returns (uint256 _id);
    function sellbyExactBNB(address Contract_, uint BNB_) external returns (uint256 _id);
    function buybyExactBNB(address Contract_, uint BNB_) external returns (uint256 _id);
    function buybyExactTokens(address Contract_, uint Tokens_, uint MaxBNB_) external returns (uint256 _id);
    function withdrawOtherTokens (address _token, address _account) external;
    function withdrawExcessBNB (address _account) external;
    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256 amountOutMins);
    function getBNBBalance() external view returns(uint BNBBalance);
    function getActionDetails(uint256 _id) external view returns (string memory Action, address Owner, string memory Name, address Contract, uint BNB, uint Tokens, uint Time);
    function getActionIds() external view returns (uint256[] memory allActionIds);
    function getContractIds(address Contract_) external view returns (uint256[] memory);
    function getTokenBalance(address Contract_) external view returns(uint CoinBalance);
 }
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
 } 
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
   function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
contract SalmonSwapSatelite is Ownable, SS {
    using Address for address;
    using Address for address payable;
    address private SSCA;
    event TokenWithdrawn (address indexed token, address indexed account, uint256 amount);
    event BNBWithdrawn (address indexed account, uint256 amount);
    constructor (address SSCA_) {
        SSCA = SSCA_;
     }
    function sellbyExactTokens(address Contract_, uint tokens_) external onlyTeam override returns (uint256 _id) {
        return SS(SSCA).sellbyExactTokens(Contract_, tokens_);
    }
    function sellbyExactBNB(address Contract_, uint BNB_) external onlyTeam override returns (uint256 _id) {
        return SS(SSCA).sellbyExactBNB(Contract_, BNB_);
    }
    function buybyExactBNB(address Contract_, uint BNB_) external onlyTeam override returns (uint256 _id) {
        return SS(SSCA).buybyExactBNB(Contract_, BNB_);
    }
    function buybyExactTokens(address Contract_, uint Tokens_, uint MaxBNB_) external onlyTeam override returns (uint256 _id) {
        return SS(SSCA).buybyExactTokens(Contract_, Tokens_, MaxBNB_);   
    }
    function withdrawOtherTokens (address _token, address _account) external onlyTeam override {
        SS(SSCA).withdrawOtherTokens (_token, _account);
    }
    function withdrawExcessBNB (address _account) external onlyTeam override {
        return SS(SSCA).withdrawExcessBNB (_account);
    }
    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view override returns (uint256 Amount) {
        return SS(SSCA).getAmountOutMin(_tokenIn, _tokenOut, _amountIn);
    }
    function getBNBBalance() external view override returns(uint BNBBalance) {
        return SS(SSCA).getBNBBalance();
    }
    function getActionDetails(uint256 _id) external view override returns(string memory Action, address Owner, string memory Name, address Contract, uint BNB, uint Tokens, uint Time) {
        return SS(SSCA).getActionDetails(_id);
    }
    function getActionIds() external view override returns(uint256[] memory allActionIds) {
        return SS(SSCA).getActionIds();
    }
    function getContractIds(address Contract_) external view  override returns (uint256[] memory Ids) {
        return SS(SSCA).getContractIds(Contract_);
    }
    function getTokenBalance(address Contract_) external view override returns(uint CoinBalance) {
        return SS(SSCA).getTokenBalance(Contract_);
    }
    function withdrawTokens (address _token, address _account) external onlyTeam {
        IERC20 token = IERC20(_token);
        uint tokenBalance = token.balanceOf(address(this));
        token.transfer (_account, tokenBalance);
        emit TokenWithdrawn (_token, _account, tokenBalance);
    }
    function withdrawBNB (address _account) external onlyTeam {
        uint256 contractBNBBalance = address(this).balance;
        if (contractBNBBalance > 0)
        payable(_account).sendValue(contractBNBBalance);
        emit BNBWithdrawn (_account, contractBNBBalance);
    }
}