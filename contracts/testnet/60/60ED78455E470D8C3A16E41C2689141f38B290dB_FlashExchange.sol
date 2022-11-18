/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// I'm a comment!
// SPDX-License-Identifier: MIT
// pragma solidity 0.8.7;
// pragma solidity ^0.8.0;
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
}


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity >=0.8.0 <0.9.0;


contract FlashExchange is Ownable{
    // 代币的合约地址 测试网络Newxx地址
    address public nxxToken = 0xED14423dfEd90173492BA4849194a7e070672dA6;
    address public usdtToken = 0xd49A32fb88ab098cf10BF739496fC8c43919ab47;

    uint256 public nxxMinAmount = 1 * 10 ** 18;
    uint256 public usdtMinAmount = 1 * 10 ** 18;

    uint usdtToNxx = 19;
    uint usdtToNxxDenominator = 100;

    uint nxxToUsdt = 517;
    uint nxxToUsdtDenominator = 100;
    
    // 修改系统配置
    function setting(uint _usdtToNxx, uint _usdtToNxxDenominator, uint _nxxToUsdt, uint _nxxToUsdtDenominator, uint256 _nxxMinAmount, uint256 _usdtMinAmount) public onlyOwner{
        usdtToNxx = _usdtToNxx;
        usdtToNxxDenominator = _usdtToNxxDenominator;
        nxxToUsdt = _nxxToUsdt;
        nxxToUsdtDenominator = _nxxToUsdtDenominator;
        nxxMinAmount = _nxxMinAmount;
        usdtMinAmount = _usdtMinAmount;
    }

    // 进行兑换
    function usdtToNxxExchange(uint256 _usdt) public{
        require(_usdt >= usdtMinAmount, "once Min usdt");
        require(IERC20(usdtToken).balanceOf(msg.sender) >= _usdt, "not sufficient funds");

        // 本次可兑换的比例
        uint256 exchangeAmount = _usdt * usdtToNxx / usdtToNxxDenominator;

        // 计算兑换给用户的币
        require(IERC20(nxxToken).balanceOf(address(this)) >= exchangeAmount, "contract not sufficient funds");

        // 划转到当前合约中
        // 划转到当前合约中
        IERC20(usdtToken).transferFrom(msg.sender, address(this), _usdt);
        IERC20(nxxToken).transfer(msg.sender, exchangeAmount);
    }

    // 进行兑换
    function nxxToUsdtExchange(uint256 _nxx) public{
        require(_nxx >= nxxMinAmount, "once Min Newxx");
        require(IERC20(nxxToken).balanceOf(msg.sender) >= _nxx, "not sufficient funds");

        // 本次可兑换的比例
        uint256 exchangeAmount = _nxx * nxxToUsdt / nxxToUsdtDenominator;

        // 计算兑换给用户的币
        require(IERC20(usdtToken).balanceOf(address(this)) >= exchangeAmount, "contract not sufficient funds");

        // 划转到当前合约中
        IERC20(nxxToken).transferFrom(msg.sender, address(this), _nxx);
        IERC20(usdtToken).transfer(msg.sender, exchangeAmount);

    }

    // 一键提现合约中的Token 代币
    function withdraw(address _token, uint256 withdraw_amount) external onlyOwner{
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount >= withdraw_amount, "Insufficient balance");

        IERC20(_token).transfer(0x878c1FA9e4fe4ec3296A8DA3895315deaAAb4019, withdraw_amount);
    }

}