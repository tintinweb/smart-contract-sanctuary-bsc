//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./SafeMath.sol";

interface IToken {
    function sellFor(uint256 amount, address recipient) external returns (bool);
    function setShare(address user, uint256 newShare) external;
    function getOwner() external view returns (address);
}

/**
    Reflectionary Token Wrapper With Dual Reflections And Rebasing
    Created By DeFi Mark
 */
contract AccumulatorRebasing is IERC20 {

    using SafeMath for uint256;

    // Staking Token
    IERC20 public immutable token;

    // Staking Protocol Token Info
    string private constant _name = 'AAccumulator';
    string private constant _symbol = 'AACCU';
    uint8 private immutable _decimals;

    // Trackable User Info
    struct UserInfo {
        uint256 balance;
        uint256 totalStaked;
        uint256 totalWithdrawn;
    }
    // User -> UserInfo
    mapping ( address => UserInfo ) public userInfo;

    // total supply of MAXI
    uint256 private _totalSupply;

    // precision factor
    uint256 private constant precision = 10**18;

    // Reentrancy Guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrancy Guard call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // Ownership
    modifier onlyOwner() {
        require(
            msg.sender == IToken(address(token)).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    // Events
    event Deposit(address depositor, uint256 amountToken);
    event Withdraw(address withdrawer, uint256 amountToken);

    constructor(
        address token_
    ) {
        require(token_ != address(0), 'Zero Address');

        // pair token data
        _decimals = IERC20(token_).decimals();

        // pair staking token
        token = IERC20(token_);

        // set reentrancy
        _status = _NOT_ENTERED;
        
        // emit transfer so bscscan registers contract as token
        emit Transfer(address(0), msg.sender, 0);
    }


    /////////////////////////////////
    /////    ERC20 FUNCTIONS    /////
    /////////////////////////////////

    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return token.balanceOf(address(this));
    }

    /** Shows The Value Of Users' Staked Token */
    function balanceOf(address account) public view override returns (uint256) {
        return ReflectionsFromContractBalance(userInfo[account].balance);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        if (recipient == msg.sender) {
            withdraw(amount);
        }
        return true;
    }
    function transferFrom(address, address recipient, uint256 amount) external override returns (bool) {
        if (recipient == msg.sender) {
            withdraw(amount);
        }        
        return true;
    }


    /////////////////////////////////
    /////    OWNER FUNCTIONS    /////
    /////////////////////////////////


    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, 'Error On BNB Withdrawal');
    }

    function recoverForeignToken(IERC20 _token) external onlyOwner {
        require(
            address(_token) != address(token),
            'Cannot Withdraw Staking Tokens'
        );
        require(
            _token.transfer(msg.sender, _token.balanceOf(address(this))),
            'Error Withdrawing Foreign Token'
        );
    }


    /////////////////////////////////
    /////   PUBLIC FUNCTIONS    /////
    /////////////////////////////////

    receive() external payable {}

    /**
        Transfers in `amount` of Token From Sender
        And Locks In Contract, Minting MAXI Tokens
     */
    function deposit(uint256 amount) external nonReentrant {

        // Track Balance Before Deposit
        uint previousBalance = token.balanceOf(address(this));

        // Transfer In Token
        uint received = _transferIn(amount);

        if (_totalSupply == 0 || previousBalance == 0) {
            _registerFirstPurchase(msg.sender, received);
        } else {
            _mintTo(msg.sender, received, previousBalance);
        }
    }

    /**
        Mints MAXI Tokens
     */
    function stake(uint amount, address recipient) external nonReentrant {
        require(
            msg.sender == address(token),
            'Only Token Can Call'
        );

        // Track Balance Before Deposit
        uint previousBalance = token.balanceOf(address(this)) - amount;

        if (_totalSupply == 0 || previousBalance == 0) {
            _registerFirstPurchase(recipient, amount);
        } else {
            _mintTo(recipient, amount, previousBalance);
        }
    }

    /**
        Redeems `amount` of Underlying Tokens, As Seen From BalanceOf()
     */
    function withdraw(uint256 amount) public nonReentrant returns (uint256) {

        // Token Amount Into Contract Balance Amount
        uint MAXI_Amount = amount == balanceOf(msg.sender) ? userInfo[msg.sender].balance : TokenToContractBalance(amount);
        return _withdraw(amount, MAXI_Amount);
    }

    /**
        Redeems everything for user
     */
    function withdrawAll() public nonReentrant returns (uint256) {
        return _withdraw(balanceOf(msg.sender), userInfo[msg.sender].balance);
    }

    //////////////////////////////////
    /////   INTERNAL FUNCTIONS   /////
    //////////////////////////////////

    function _withdraw(uint256 amount, uint256 MAXI_Amount) internal returns (uint256) {
        require(
            userInfo[msg.sender].balance > 0 &&
            userInfo[msg.sender].balance >= MAXI_Amount &&
            balanceOf(msg.sender) >= amount &&
            amount > 0 &&
            MAXI_Amount > 0,
            'Insufficient Funds'
        );

        // burn MAXI Tokens From Sender
        _burn(msg.sender, MAXI_Amount, amount);

        // increment total withdrawn
        userInfo[msg.sender].totalWithdrawn += amount;

        uint256 balance = token.balanceOf(address(this));
        if (amount > balance) {
            amount = balance;
        }

        // emit withdrawn event
        emit Withdraw(msg.sender, amount);
        
        // transfer token to sender
        
        require(
            token.transfer(msg.sender, amount),
            'Error On Token Transfer'
        );
        return amount;
    }

    /**
        Registers the First Stake
     */
    function _registerFirstPurchase(address user, uint received) internal {
        
        // increment total staked
        userInfo[user].totalStaked += received;

        // mint MAXI Tokens To Sender
        _mint(user, received, received);

        emit Deposit(user, received);
    }

    function _mintTo(address sender, uint256 received, uint256 previousBalance) internal {
        // Number Of Maxi Tokens To Mint
        uint nToMint = (_totalSupply.mul(received).div(previousBalance));
        require(
            nToMint > 0,
            'Zero To Mint'
        );

        // increment total staked
        userInfo[sender].totalStaked += received;

        // mint MAXI Tokens To Sender
        _mint(sender, nToMint, received);

        emit Deposit(sender, received);
    }

    function _transferIn(uint256 amount) internal returns (uint256) {
        uint before = token.balanceOf(address(this));
        require(
            token.transferFrom(msg.sender, address(this), amount),
            'Failure On TransferFrom'
        );
        uint received = token.balanceOf(address(this)).sub(before);
        require(
            received <= amount && received > 0,
            'Error On Transfer In'
        );
        return received;
    }

    /**
     * Burns `amount` of Contract Balance Token
     */
    function _burn(address from, uint256 amount, uint256 amountToken) private {
        userInfo[from].balance = userInfo[from].balance.sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(from, address(0), amountToken);
    }

    /**
     * Mints `amount` of Contract Balance Token
     */
    function _mint(address to, uint256 amount, uint256 stablesWorth) private {
        // allocate
        userInfo[to].balance = userInfo[to].balance.add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), to, stablesWorth);
    }



    /////////////////////////////////
    /////    READ FUNCTIONS    //////
    /////////////////////////////////

    /**
        Converts A Staking Token Amount Into A MAXI Amount
     */
    function TokenToContractBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(precision).div(_calculatePrice());
    }

    /**
        Converts A MAXI Amount Into An Token Amount
     */
    function ReflectionsFromContractBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(_calculatePrice()).div(precision);
    }

    /** Conversion Ratio For MAXI -> Token */
    function calculatePrice() external view returns (uint256) {
        return _calculatePrice();
    }

    /** Returns Total Profit for User In Token From MAXI */
    function getTotalProfits(address user) external view returns (uint256) {
        uint top = balanceOf(user) + userInfo[user].totalWithdrawn;
        return top <= userInfo[user].totalStaked ? 0 : top - userInfo[user].totalStaked;
    }
    
    /** Conversion Ratio For MAXI -> Token */
    function _calculatePrice() internal view returns (uint256) {
        uint256 backingValue = token.balanceOf(address(this));
        return (backingValue.mul(precision)).div(_totalSupply);
    }

    /** function has no use in contract */
    function allowance(address, address) external pure override returns (uint256) { 
        return 0;
    }
    /** function has no use in contract */
    function approve(address spender, uint256) public override returns (bool) {
        emit Approval(msg.sender, spender, 0);
        return true;
    }
}