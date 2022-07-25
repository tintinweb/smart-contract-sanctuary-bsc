//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./SafeMath.sol";

interface IToken {
    function sellFor(uint256 amount, address recipient) external returns (bool);
    function setShare(address user, uint256 newShare) external;
    function getOwner() external view returns (address);
}

interface IDistributor {
    function setShare(address user, uint256 newShare) external;
}

/**
    Reflectionary Token Wrapper With Dual Reflections
    Created By DeFi Mark
 */
contract DualReflectionStaking is IERC20 {

    using SafeMath for uint256;

    // Staking Token
    IERC20 public immutable token;

    // Staking Protocol Token Info
    string private constant _name = 'DFA MAXI';
    string private constant _symbol = 'DFA MAXI';
    uint8 private immutable _decimals;

    // Trackable User Info
    struct UserInfo {
        uint256 balance;
        uint256 unlockBlock;
        uint256 totalStaked;
        uint256 totalWithdrawn;
    }
    // User -> UserInfo
    mapping ( address => UserInfo ) public userInfo;

    // Unstake Early Fee
    uint256 public leaveEarlyFee = 50;

    // Timer For Leave Early Fee
    uint256 public leaveEarlyFeeTimer = 201600;

    // total supply of MAXI
    uint256 private _totalSupply;

    // Swapper To Purchase Token From BNB
    address public tokenSwapper;

    // Reward Distributor
    address public distributor;

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
    event FeeTaken(uint256 fee);

    constructor(
        address token_, 
        address tokenSwapper_
    ) {

        require(token_ != address(0), 'Zero Address');
        require(tokenSwapper_ != address(0), 'Zero Address');

        // pair token data
        _decimals = IERC20(token_).decimals();

        // pair staking token
        token = IERC20(token_);
        tokenSwapper = tokenSwapper_;

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
            withdraw(amount, true);
        }
        return true;
    }
    function transferFrom(address, address recipient, uint256 amount) external override returns (bool) {
        if (recipient == msg.sender) {
            withdraw(amount, true);
        }        
        return true;
    }


    /////////////////////////////////
    /////    OWNER FUNCTIONS    /////
    /////////////////////////////////

    function setLeaveEarlyFee(uint256 newLeaveEarlyFee) external onlyOwner {
        require(
            newLeaveEarlyFee <= 100,
            'Early Fee Too High'
        );
        leaveEarlyFee = newLeaveEarlyFee;
    }
    function setLeaveEarlyFeeTimer(uint256 newLeaveEarlyFeeTimer) external onlyOwner {
        require(
            newLeaveEarlyFeeTimer <= 10**7,
            'Fee Timer Too High'
        );
        leaveEarlyFeeTimer = newLeaveEarlyFeeTimer;
    }
    function setTokenSwapper(address newTokenSwapper) external onlyOwner {
        require(
            newTokenSwapper != address(0),
            'Zero Address'
        );
        tokenSwapper = newTokenSwapper;
    }
    function setRewardDistributor(address newDistributor) external onlyOwner {
        require(
            newDistributor != address(0),
            'Zero Address'
        );
        distributor = newDistributor;
    }

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

    /** Native Sent To Contract Will Buy And Stake Token
        Standard Token Purchase Rates Still Apply
     */
    receive() external payable {
        require(msg.value > 0, 'Zero Value');
        require(_status != _ENTERED, "Reentrancy Guard call");

        // enable reentrancy lock
        _status = _ENTERED;

        // Track Balance Before Deposit
        uint previousBalance = token.balanceOf(address(this));

        // Purchase Staking Token
        uint received = _buyToken(msg.value);

        // mint appropriate balance to recipient
        if (_totalSupply == 0 || previousBalance == 0) {
            _registerFirstPurchase(received);
        } else {
            _mintTo(msg.sender, received, previousBalance);
        }

        // set share for user
        IDistributor(distributor).setShare(msg.sender, userInfo[msg.sender].balance);

        // disable reetrancy lock
        _status = _NOT_ENTERED;
    }

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
            _registerFirstPurchase(received);
        } else {
            _mintTo(msg.sender, received, previousBalance);
        }

        // set share for user
        IDistributor(distributor).setShare(msg.sender, userInfo[msg.sender].balance);
    }

    /**
        Redeems `amount` of Underlying Tokens, As Seen From BalanceOf()
     */
    function withdraw(uint256 amount, bool forETH) public nonReentrant returns (uint256) {

        // Token Amount Into Contract Balance Amount
        uint MAXI_Amount = amount == balanceOf(msg.sender) ? userInfo[msg.sender].balance : TokenToContractBalance(amount);
        return _withdraw(amount, MAXI_Amount, forETH);
    }

    /**
        Redeems everything for user
     */
    function withdrawAll(bool forETH) public nonReentrant returns (uint256) {
        return _withdraw(balanceOf(msg.sender), userInfo[msg.sender].balance, forETH);
    }

    function donate() external payable nonReentrant {
        // buy staking token
        _buyToken(address(this).balance);
    }



    //////////////////////////////////
    /////   INTERNAL FUNCTIONS   /////
    //////////////////////////////////

    function _withdraw(uint256 amount, uint256 MAXI_Amount, bool forETH) internal returns (uint256) {
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

        // Take Fee If Withdrawn Before Timer
        uint fee = remainingLockTime(msg.sender) == 0 ? 0 : _takeFee(amount.mul(leaveEarlyFee).div(1000));

        // send amount less fee
        uint256 sendAmount = amount.sub(fee);
        uint256 balance = token.balanceOf(address(this));
        if (sendAmount > balance) {
            sendAmount = balance;
        }

        // emit withdrawn event
        emit Withdraw(msg.sender, sendAmount);

        // set share for user
        IDistributor(distributor).setShare(msg.sender, userInfo[msg.sender].balance); 
        
        // transfer token to sender
        if (forETH) {
            require(
                IToken(address(token)).sellFor(sendAmount, msg.sender),
                'Error Selling Tokens For Sender'
            );
        } else {
            require(
                token.transfer(msg.sender, sendAmount),
                'Error On Token Transfer'
            );
        }
        return sendAmount;
    }

    /**
        Registers the First Stake
     */
    function _registerFirstPurchase(uint received) internal {
        
        // increment total staked
        userInfo[msg.sender].totalStaked += received;

        // mint MAXI Tokens To Sender
        _mint(msg.sender, received, received);

        emit Deposit(msg.sender, received);
    }


    function _takeFee(uint256 fee) internal returns (uint256) {
        emit FeeTaken(fee);
        return fee;
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

    function _buyToken(uint amount) internal returns (uint256) {
        require(
            amount > 0,
            'Zero Amount'
        );
        uint before = token.balanceOf(address(this));
        (bool s,) = payable(tokenSwapper).call{value: amount}("");
        require(s, 'Failure On Token Purchase');
        uint received = token.balanceOf(address(this)).sub(before);
        require(received > 0, 'Zero Received');
        return received;
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
        // update locker info
        userInfo[msg.sender].unlockBlock = block.number + leaveEarlyFeeTimer;
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

    /**
        Lock Time Remaining For Stakers
     */
    function remainingLockTime(address user) public view returns (uint256) {
        return userInfo[user].unlockBlock < block.number ? 0 : userInfo[user].unlockBlock - block.number;
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