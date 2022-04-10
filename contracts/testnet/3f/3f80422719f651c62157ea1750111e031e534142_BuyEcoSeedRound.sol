/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/*
 * @title: SafeMath
 * @dev: Helper contract functions to arithmatic operations safely.
 */
contract SafeMath {
    function Sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function Add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function Divisable(uint256 a, uint256 b) internal pure returns (bool) {
        require(b <= a, "SafeMath: subtraction overflow");
        return (a % b == 0);
    }

    function Mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function Div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
}

/*
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface Token {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract BuyEcoSeedRound is Ownable, SafeMath {
    address public TOKEN_TO_BUY_ECO;
    uint256 public ecoPrice = 150000000000000000;

    address[] public investers;

    mapping(address => uint256) vestingAmounts;
    mapping(address => bool) isInvested;

    event Invested(address invester, uint256 amount);

    constructor(address _tokenBuyAddress, uint256 _ecoPrice) {
        TOKEN_TO_BUY_ECO = _tokenBuyAddress;
        ecoPrice = _ecoPrice;
    }

    function setInvesters(
        address[] memory _investers,
        uint256[] memory _vestingAmounts
    ) public {
        investers = _investers;

        for(uint256 i; i < _investers.length; i++){
            vestingAmounts[_investers[i]] = _vestingAmounts[i];
        }
    }

    function getInvestAmount(address _invester) public view returns(uint256){
        return vestingAmounts[_invester];
    }

    function getEcoReceivingAmount(address _invester) public view returns(uint256){
        return Div(vestingAmounts[_invester], ecoPrice);
    }

    function checkInvested(address _invester) public view returns(bool) {
        return isInvested[_invester];
    }

    function setBuyToken(address _tokenAddress) public onlyOwner {
        TOKEN_TO_BUY_ECO = _tokenAddress;
    }

    function buyEco() public {     
        require(Token(TOKEN_TO_BUY_ECO).transferFrom(_msgSender(), owner(), vestingAmounts[msg.sender]));   
        isInvested[msg.sender] = true;
        emit Invested(msg.sender, vestingAmounts[msg.sender]);
    }

    function withdrawBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }
}