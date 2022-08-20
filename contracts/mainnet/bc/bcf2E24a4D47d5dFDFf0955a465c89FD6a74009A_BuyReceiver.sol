//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IOpRise {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract BuyReceiver {

    // token
    address public immutable token;

    // Recipients Of Fees
    address public reliefFund;
    address public marketing;

    // Trust Fund Allocation
    uint256 public reliefFundPercentage;
    uint256 public marketingPercentage;
    uint256 public percentageDenom;

    // Bounty Percent
    uint256 public bountyPercent = 20; // 2%

    modifier onlyOwner(){
        require(
            msg.sender == IOpRise(token).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address token_, address reliefFund_, address marketing_) {
        require(
            token_ != address(0) &&
            reliefFund_ != address(0) &&
            marketing_ != address(0),
            'Zero Address'
        );

        // Initialize Addresses
        token = token_;
        reliefFund = reliefFund_;
        marketing = marketing_;

        // trust fund percentage
        reliefFundPercentage = 5;
        marketingPercentage  = 2;
        percentageDenom      = 15;
    }

    function trigger() external {

        // get bounty and send to caller
        uint bounty = currentBounty();
        if (bounty > 0) {
            _send(msg.sender, bounty);
        }

        // Balance In Contract
        uint balance = balanceOf();

        // fraction out tokens
        uint rFund = balance * reliefFundPercentage / percentageDenom;
        uint mFund = balance * marketingPercentage / percentageDenom;

        // send to destinations
        _send(reliefFund, rFund);
        _send(marketing, mFund);

        // burn rest
        balance = balanceOf();
        if (balance > 0) {
            IOpRise(token).burn(balance);
        }
    }

    function setReliefFund(address tFund) external onlyOwner {
        require(tFund != address(0));
        reliefFund = tFund;
    }
    
    function setMarketing(address marketing_) external onlyOwner {
        require(marketing_ != address(0));
        marketing = marketing_;
    }

    function setBountyPercent(uint256 newBounty) external onlyOwner {
        require(newBounty <= 500);
        bountyPercent = newBounty;
    }
   
    function setPercentages(uint256 reliefFundPercent, uint256 marketingPercent, uint256 burnPercent) external onlyOwner {
        reliefFundPercentage = reliefFundPercent;
        marketingPercentage = marketingPercent;
        percentageDenom = reliefFundPercent + marketingPercent + burnPercent;
    }
    
    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
    
    receive() external payable {}

    function _send(address recipient, uint amount) internal {
        bool s = IERC20(token).transfer(recipient, amount);
        require(s, 'Failure On Token Transfer');
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function currentBounty() public view returns (uint256) {
        return ( balanceOf() * bountyPercent ) / 1000;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}