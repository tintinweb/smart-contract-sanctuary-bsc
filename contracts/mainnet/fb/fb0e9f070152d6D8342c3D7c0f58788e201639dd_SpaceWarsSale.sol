// SPDX-License-Identifier: MIT

import "./ownable.sol";
import "./safeMath.sol";
import "./IBEP20.sol";

pragma solidity 0.8.7;

contract SpaceWarsSale is Ownable {
    using SafeMath for uint256;

    // The token being sold
    IBEP20 public token;

    // Address where funds are collected
    address payable public wallet;

    // How many token units a buyer gets per wei
    uint256 public rate;

    // Amount of wei raised
    uint256 public weiRaised;

    bool public isSaleEnded;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * Event for rate upate loging
     * @param newRate new rate value
     */
    event RateUpdated(uint256 newRate);

    constructor(
        uint256 _rate,
        address payable _wallet,
        IBEP20 _token
    ) {
        require(_rate > 0);
        require(_wallet != address(0));

        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }

    modifier hasTokens() {
        require(token.balanceOf(address(this)) > 0, "No tokens left");
        _;
    }

    modifier isVestingFinished() {
        require(isSaleEnded, "Vesting Not Over");
        _;
    }

    modifier isVestingGoingOn() {
        require(!isSaleEnded, "Vesting Already Ended");
        _;
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Address performing the token purchase
     */
    function buyTokens(address _beneficiary) public payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        _deliverTokens(_beneficiary, tokens);
        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        _forwardFunds();
    }

    /**
     * @dev only owner can changes rate
     * @param _newRate new rate value
     */
    function changeRate(uint256 _newRate) public onlyOwner {
        require(_newRate > 0, "Zero Rate");
        rate = _newRate;
        emit RateUpdated(_newRate);
    }

    /// @notice Ends Vesting
    /// @dev Only owners can call this when vesting is going on
    function endVesting() public onlyOwner isVestingGoingOn {
        isSaleEnded = true;
    }

    /// @notice Start/Restart Vesting
    /// @dev Only owners can call this when vesting is going on
    function startVesting() public onlyOwner isVestingFinished {
        isSaleEnded = false;
    }

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        view
        isVestingGoingOn
        hasTokens
    {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
     * @param _beneficiary Address performing the token purchase
     * @param _tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        token.transfer(_beneficiary, _tokenAmount);
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param _weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount.mul(rate);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    function sendTokensBack() external onlyOwner isVestingFinished {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}