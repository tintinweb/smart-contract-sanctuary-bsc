// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "./Context.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./Ownable.sol";

/**
 * @author ~ 🅧🅘🅟🅩🅔🅡 ~
 * @title SolarSale V2.0
 *
 * @dev SolarSale V2.0 is a crowdsale contract that is bound by the rules
 * and limitations of a whitelist. It is intended to be used to gather funding
 * for an upcoming token.
 *
 * ░██████╗░█████╗░██╗░░░░░░█████╗░██████╗░░██████╗░█████╗░██╗░░░░░███████╗
 * ██╔════╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗██║░░░░░██╔════╝
 * ╚█████╗░██║░░██║██║░░░░░███████║██████╔╝╚█████╗░███████║██║░░░░░█████╗░░
 * ░╚═══██╗██║░░██║██║░░░░░██╔══██║██╔══██╗░╚═══██╗██╔══██║██║░░░░░██╔══╝░░
 * ██████╔╝╚█████╔╝███████╗██║░░██║██║░░██║██████╔╝██║░░██║███████╗███████╗
 * ╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚══════╝╚══════╝
 */
contract SolarSale is Context, ReentrancyGuard, Ownable
{    
    address public claimable;
    address public wallet;

    address[] public whitelist;

    uint public hardCap;
    uint public allocationCap;

    uint public numerator;
    uint public denominator;

    uint public openingTime;
    uint public closingTime;
    bool public claimOpen;

    uint public subjectRaised;

    mapping(address => uint) public contributions;
    mapping(address => bool) public hasClaimed;

    event Contributed(address indexed user, uint value);
    event Claimed(address indexed user, uint value);
    event DurationExtended(uint currentClosingTime, uint newClosingTime);

    modifier onlyWhileOpen 
    {
        require(isOpen(), "SolarSale: Not Open");
        _;
    }

    constructor(address token_, uint hardCap_, uint allocationCap_, uint numerator_, uint denominator_, uint openingTime_, uint closingTime_)
    {
        require(numerator_ > 0 && denominator_ > 0, "SolarSale: Rate is 0");

        claimable = token_;
        wallet = address(this);

        hardCap = hardCap_;
        allocationCap = allocationCap_;

        numerator = numerator_;
        denominator = denominator_;

        openingTime = openingTime_;
        closingTime = closingTime_;

        claimOpen = false;
    }

    function getTokenAmount(uint amount) public view returns (uint)
    {
        return (amount * numerator) / denominator;
    }

    function getPurchasableAmount(address wallet_, uint amount) public view returns (uint)
    {
        if (contributions[wallet_] > allocationCap || address(this).balance >= hardCap)
            return 0;

        amount = (amount + subjectRaised) > hardCap ? (hardCap - subjectRaised) : amount;
        return amount - contributions[wallet_];
    }

    function isOpen() public view returns (bool)
    {
        return block.timestamp >= openingTime && block.timestamp <= closingTime;
    }

    function hasClosed() public view returns (bool)
    {
        return block.timestamp > closingTime;
    }

    function isWhitelisted(address wallet_) public view returns (bool)
    {
        return verify(wallet_);
    }

    function canClaim(address user) external view returns (bool)
    {
        uint tokenAmount = getTokenAmount(contributions[user]);

        return
        !(
            !hasClosed() ||
            hasClaimed[user] ||
            tokenAmount == 0 ||
            IERC20(claimable).allowance(wallet, address(this)) < tokenAmount ||
            IERC20(claimable).balanceOf(wallet) < tokenAmount
        );
    }

    function openClaim() external onlyOwner
    {
        claimOpen = true;
    }

    function closeClaim() external onlyOwner
    {
        claimOpen = false;
    }

    function setClaimableToken(address token_) external onlyOwner
    {
        require(token_ != address(0), "SolarSale: Token is the zero address");

        claimable = token_;
    }

    function setCap(uint hardCap_, uint allocationCap_) external onlyOwner
    {
        hardCap = hardCap_;
        allocationCap = allocationCap_;
    }

    function setRate(uint numerator_, uint denominator_) external onlyOwner
    {
        require(numerator_ > 0 && denominator_ > 0, "SolarSale: Rate is 0");

        numerator = numerator_;
        denominator = denominator_;
    }

    function depositTokens(uint amount) external onlyOwner
    {
        IERC20(claimable).transferFrom(msg.sender, wallet, amount);
    }

    function withdrawContributable() external onlyOwner
    {
        payable (msg.sender).transfer(address(this).balance);
    }

    function withdrawClaimable() external onlyOwner
    {
        withdraw(claimable, msg.sender);
    }

    function withdrawOther(address token_) external onlyOwner
    {
        withdraw(token_, msg.sender);
    }

    function extendTime(uint newClosingTime) external onlyOwner
    {
        require(!hasClosed(), "SolarSale: Already closed");
        require(newClosingTime > closingTime, "SolarSale: New closing time is before current closing time");

        emit DurationExtended(closingTime, newClosingTime);

        closingTime = newClosingTime;
    }

    function addWallets(address[] memory wallets) external onlyOwner
    {
        for (uint i; i < wallets.length; i++)
            whitelist.push(wallets[i]);
    }

    function verify(address wallet_) internal view returns (bool)
    {
        for (uint i; i < whitelist.length; i++)
            if (whitelist[i] == wallet_)
                return true;

        return false;
    }

    function contribute() external payable onlyWhileOpen
    {
        uint amount = getPurchasableAmount(msg.sender, msg.value);

        require(amount > 0, "SolarSale: Purchase amount is 0.");
        require(contributions[msg.sender] + amount <= allocationCap, "SolarSale: Purchase amount is above cap.");
        require(allocationCap - contributions[msg.sender] <= allocationCap, "SolarSale: User has already purchased max amount.");
        require(verify(msg.sender), "SolarSale: Wallet is not whitelisted.");

        subjectRaised += amount;
        contributions[msg.sender] += amount;

        emit Contributed(msg.sender, amount);
    }

    function claim() external nonReentrant
    {
        require(hasClosed(), "SolarSale: Presale hasn't closed yet.");
        require(!hasClaimed[msg.sender], "SolarSale: Tokens already claimed.");
        require(claimOpen, "SolarSale: The claim hasn't been opened yet.");
        require(claimable != address(0), "SolarSale: Token hasn't been set yet.");

        uint tokenAmount = getTokenAmount(contributions[msg.sender]);
        require(tokenAmount > 0, "SolarSale: Address was not a participant.");

        IERC20(claimable).transfer(msg.sender, tokenAmount);
        hasClaimed[msg.sender] = true;

        emit Claimed(msg.sender, tokenAmount);
    }

    function withdraw(address token_, address to_) internal
    {
        IERC20(token_).transfer(to_, IERC20(token_).balanceOf(address(this)));
    }
}