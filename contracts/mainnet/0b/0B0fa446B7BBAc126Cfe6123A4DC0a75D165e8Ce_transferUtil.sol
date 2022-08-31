/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/
pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
contract Ownable {

    address public _owner;
    mapping(address => bool) public _approver;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current approver.
     */
    function approver(address targer) public view returns (bool) {
        return _approver[targer];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner. 
     */
    modifier onlyApprover() {
        require(_owner == msg.sender || _approver[msg.sender] , "Ownable: caller is not the owner or approver");
        _;
    }

    function changeOwner(address targer) public onlyOwner {
        _owner = targer;
    }

    function updateApprover(address targer,bool value) public onlyOwner { 
        _approver[targer] = value;
    }

}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

contract Util { 

    /*
     * @dev 转换位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 回退位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 浮点类型除法 a/b
     * @param a 被除数
     * @param b 除数
     * @param decimals 精度
     */
    function mathDivisionToFloat(uint256 a, uint256 b,uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals)); 
        uint256 amount = aPlus/b;
        return amount;
    }

}

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract transferUtil is Ownable, Util { 

    using SafeMath for uint256;

    uint256 private _totalTransfer;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    ERC20 private tbccContract;
    address public tbccContractAddress;
    address private transferAddress;
    
    constructor() { 
        
        _owner = msg.sender;

        tbccContractAddress = 0xf29480344d8e21EFeAB7Fde39F8D8299056A7FEA;
        tbccContract = ERC20(tbccContractAddress);
        transferAddress = 0x5BA4B309f6d332D1a239984c0AE6f7aB0916D649;

    }

    function totalTransfer() public onlyOwner view returns (uint256) {
        return _totalTransfer;
    }

    function balanceOf(address _address) public onlyOwner view returns (uint256) {
        return _balances[_address]; 
    }

    function transfer(address recipient, uint256 amount)
        public
        onlyApprover
        returns (bool) 
    { 
        TransferHelper.safeTransfer(tbccContractAddress,transferAddress,amount); 
        TransferHelper.safeTransferFrom(tbccContractAddress,transferAddress,recipient,amount); 
        _balances[recipient] += amount;
        _totalTransfer += amount;
        return true;
    }

    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts)
        public
        onlyApprover
        returns (bool) 
    { 
        for(uint i = 0 ; i <recipients.length ; i++){
            transfer(recipients[i],amounts[i]);
        }
        return true;
    }

    function setTbccContract(address _contractAddress) public onlyOwner{ 
        tbccContractAddress = _contractAddress;
        tbccContract = ERC20(tbccContractAddress);
    }

    function setTransferAddress(address _transferAddress) public onlyOwner{ 
        transferAddress = _transferAddress;
    }
    
}