/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.8.7;


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
contract Context {
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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


//This is initializing the contract
contract JBIOToken is Context, Ownable {
    //Estbalishing a record of rank and the corresponding data
    struct rankRule {
        string title;
        uint taxRateBasisPoints;
        uint nextLevelTransactions;
    }
    //Establishing the rank a given user is at and THEIR corresponding data
    struct userRank {
        string title;
        uint rank;
        uint transactions;
        uint totalOwnership;
        uint taxRateBasisPoints;
        bool verifiedEngagementStatus;
        bool verifiedStatus;
    }

    //Setting mapping for the  addresses, not entirely sure what is going on here but I know it has to do with updating balances
    mapping(address => uint) public balances;
    //Unsure here, looks like mapping for how much tokens are allowed to the public or something else?
    mapping(address => mapping(address => uint)) public allowance;
    //Just a helper setting up if the sender is excluded from the tax
    mapping (address => bool) private _isSenderExcludedFromTax;
    //Same as above but for a recipient
    mapping (address => bool) private _isRecipientExcludedFromTax;
    //Helper for setting ranking rules
    mapping(uint => rankRule) rankingRules;
    //Helper for keeping track of user ranks
    mapping(address => userRank) rankingLedger;
    //helper for blacklist
    mapping(address => bool) public isBlacklisted;

    //dev wallet
    address private _devAddress = 0x2f7E2E404bb67A22d3cE69c76faDd2C72F8313Fd;
    //Toggle for tax
    bool public isTaxActive = true;
    //adding killswitch
    bool public killSwitchEngaged = false;
    //Public token name
    string public name = "JBIO Token";
    //Public token Ticker
    string public symbol = "JBIO";
    //Total token supply
    uint public totalSupply = 100000;
    //BPS for tax
    uint public baselineDevBasisPointsTax = 1000;
    //Unsure what youre doing here, guessing establishing top rank
    uint public infiniteNextRank = 999999;
    //Starting rank
    uint public initialRank = 1;

    //Putting the transfer on the blockchain
    event Transfer(address indexed from, address indexed to, uint value);
    //Approving the transfer for the blockchain
    event Approval(address indexed owner, address indexed spender, uint value);

    //setting the constructor to initialize state variables on the contract
    constructor() {

        //setting the dev wallet as the total supply initially
        balances[_devAddress] = totalSupply;
        //Starting with the dev wallet being exempt from taxes
        _isSenderExcludedFromTax[_devAddress] = true;
        // THIS IS THE CONTRACT ADDRESS
        //Seems like this is doing the same this but unsure
        _isSenderExcludedFromTax[address(this)] = true;
        //As far as I understand emit is just transmitting info to the blockchain to be stored?
        emit Transfer(address(0), _devAddress, totalSupply);

        //setting rules for the ranking based on the function before, so private, captain, general and their basis points and corresponding transaction levels to reach it
        setRankingRules(1, "Private", 1000, 2);
        setRankingRules(2, "Captain", 500, 4);
        setRankingRules(3, "General", 50, infiniteNextRank);
    }
    //blacklists a user
    function blackListUser(address blacklistee) public onlyOwner {
        isBlacklisted[blacklistee] = true;
    }
    //whitelists a user
    function whiteListUser(address whitelistee) public onlyOwner {
        isBlacklisted[whitelistee] = false;
    }
    //checks status of user on blacklist
    function isUserBlacklisted(address user) public view returns(bool) {
        return isBlacklisted[user];
    }
    //Checks status of killswitch
    function isKillSwitchEngaged() public view returns(bool) {
        return killSwitchEngaged;
    }
    //Killswitch on Toggle
    function engageKillSwitch() public onlyOwner {
        killSwitchEngaged = true;
    }
    //Killswitch OFF toggle
    function disengageKillSwitch() public onlyOwner {
        killSwitchEngaged = false;
    }

    //Your function to toggle the tax
    function setTaxActive() public onlyOwner {
        isTaxActive = true;
    }
    //Other function to toggle the tax
    function setTaxInactive() public onlyOwner {
        isTaxActive = false;
    }
    //just a getter for if tax is active or not (checking status)
    function getTaxActive() public view returns(bool) {
        return isTaxActive;
    }
    //White list for tax evasion (Al Sharpton)
    function excludeSenderFromTax(address account) public onlyOwner {
        _isSenderExcludedFromTax[account] = true;
    }
    //IRS after Wesley Snipes
    function includeSenderInTax(address account) public onlyOwner {
        _isSenderExcludedFromTax[account] = false;
    }
    //Wesley Snipes from IRS (except he's checking if he is excluded)
    function isExcludedSenderFromTax(address account) public view returns(bool) {
        return _isSenderExcludedFromTax[account];
    }
    //What Wesley Snipes wishes he could do with his wallet
    function excludeRecipientFromTax(address account) public onlyOwner {
        _isRecipientExcludedFromTax[account] = true;
    }
    //What Wesley Snipes legally is obligated to do with his wallet
    function includeRecipientInTax(address account) public onlyOwner {
        _isRecipientExcludedFromTax[account] = false;
    }
    //just a getter for checking to see if an account is excluded from taxes
    function isExcludedRecipientFromTax(address account) public view returns(bool) {
        return _isRecipientExcludedFromTax[account];
    }

    //Pretty sure you're setting someone's rank and what not here, and the corresponding stuff
    function setRankingRules(uint rank, string memory title, uint basisPoints, uint transactions) public onlyOwner returns(rankRule memory)  {
        rankingRules[rank].title = title;
        rankingRules[rank].taxRateBasisPoints = basisPoints;
        rankingRules[rank].nextLevelTransactions= transactions;
        //seeing someone's rank?
        return rankingRules[rank];
    }
    //Getter for a certain rank "title"
    function getRankRule(uint rank) public view returns(rankRule memory) {
        return rankingRules[rank];
    }
    //Setting someone's rank or the initial rank for the variable
    function setInitialRank(uint rank) public onlyOwner returns (uint) {
        initialRank = rank;

        return initialRank;
    }
    //Getter for initial rank (guessing on whole contract?)
    function getInitialRank() public view returns(uint) {
        return initialRank;
    }
    //Setter for user rank
    function setUserRank(address user, uint rank, bool init) public returns(userRank memory) {
        rankRule memory newRank = getRankRule(rank);
        rankingLedger[user].title = newRank.title;
        rankingLedger[user].rank = rank;
        rankingLedger[user].taxRateBasisPoints= newRank.taxRateBasisPoints;
        //This part is checking if someone's first time, if yes, you set all their shit to zero?
        if (init) {
            rankingLedger[user].transactions = 0;
            rankingLedger[user].totalOwnership = 0;
            rankingLedger[user].verifiedEngagementStatus = false;
            rankingLedger[user].verifiedStatus = false;
        }
        //returning the user's rank according to the rules
        return rankingLedger[user];
    }
    //getter for user rank
    function getUserRank(address user) public view returns(userRank memory) {
        return rankingLedger[user];
    }
    //setter for user verified status
    function setUserVerifiedStatus(address user, bool status) public onlyOwner returns(bool) {
        rankingLedger[user].verifiedStatus = status;

        return rankingLedger[user].verifiedStatus;

    }

    //setter for user verified engagement status (we did discuss this but kinda makes sense, unsure how this is different from rank, guessing it's involved with the social media stuff discussed)
    function setUserVerifiedEngagementStatus(address user, bool status) public onlyOwner returns(bool) {
        rankingLedger[user].verifiedEngagementStatus = status;

        return rankingLedger[user].verifiedEngagementStatus;
    }
    //Unsure what's going on here. You're incrementing their transactions, submitting their rank to memory, checking to see if their current rank is below what it would be according to the rule after incrementing their transactions, then if it is you're resetting it higher or to whatever it should be
    function evaluateRankAndTrack(address user) public {
        rankingLedger[user].transactions++;
        userRank memory userRankInfo = getUserRank(user);
        rankRule memory currentRank = getRankRule(userRankInfo.rank);
        if (rankingLedger[user].transactions >= currentRank.nextLevelTransactions && currentRank.nextLevelTransactions != infiniteNextRank){
            uint nextRank = userRankInfo.rank + 1;
            setUserRank(user, nextRank, false);
        }
    }

    //Just a getter for balance of a given wallet
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    //transfer function, takes in new wallet, and how much to transfer, send it, returns true so I'm guessing that it can be used in conjunction with the approval function or something like that
    function transfer(address to, uint value) public returns(bool)  {
        _transfer(msg.sender, to, value);

        return true;
    }

    //Basically the same as above but checking if theres enough balance
    //I'll bet there's an AND conditional somewhere when you're running these to check if the balances are ok enough and both must be true
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        _transfer(from, to, value);

        return true;
    }

    //actual transfer function, the requires make it so that these things be true or valid to proceed, you've got throw errors/warnings after each on if they're not
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(!isKillSwitchEngaged(), "KillSwitch is engaged and rocking, please come back later");
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "User is on Blacklist or sending to blacklist, begone trash");
        require(balanceOf(sender) >= amount, 'Balance too low');
        require(sender != address(0), "BEP20: Transfer from the zero address");
        require(recipient != address(0), "BEP20: Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        //adding tax
        bool isTransactionTaxable = true;
        //Part the reciever will get
        uint shareForRecipient = amount;
        //updating balance for sender
        balances[sender] -= amount;

        //Checking if you're adding in the tax via checking sender/catcher to see if theyr eligible for the tax
        if(_isSenderExcludedFromTax[sender] || _isRecipientExcludedFromTax[recipient]) {
            isTransactionTaxable = false;
        }

        //Checking for tax again (Wesley Snipes and IRS) but this time also checking for the && for if the transaction is taxable AND the tax is active
        if(isTransactionTaxable && isTaxActive) {
            //BPS for tax
            uint taxBasisPointForTransaction = baselineDevBasisPointsTax;
            //Checking to see if the user gets a tax discount (what wesley snipes wishes he had)
            userRank memory userRankInfo = getUserRank(sender);
            //Setting wesley snipes and IRS if it's greater than 0 for the USER
            if (userRankInfo.taxRateBasisPoints > 0) {
                taxBasisPointForTransaction = userRankInfo.taxRateBasisPoints;
            } else {
                //Just looks like you're checking the user again for tax but this part is for an initial ranking, unsure why you added this, doesn't if above cover this already?
                setUserRank(sender, initialRank, true);
            }
            //establishing the variable of the share for the developers (why the division by 10000 (supply)?)
            uint shareForDevs = ((amount * taxBasisPointForTransaction)/10000);

            //amount for catcher
            shareForRecipient = (amount-shareForDevs);
            //adding to the dev wallet share address
            balances[_devAddress] = (balances[_devAddress] + shareForDevs);
            //adding to the catcher address
            balances[recipient] = (balances[recipient] + shareForRecipient);

            //These just emit to the blockchain, like POST methods in an API in this instance
            emit Transfer(sender, _devAddress, shareForDevs);
            emit Transfer(sender, recipient, shareForRecipient);

            //calling the rank function from before
            evaluateRankAndTrack(sender);
        } else {
            //I think you've got this here in case someone isn't in your ranks? for the next two lines,
            //This is here for if there transaction is non taxable (Puerto Rico)
            balances[recipient] = (balances[recipient] + amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    //Finally is just the approve approving the transaction?
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        //emitting the approval to the blockchain
        emit Approval(msg.sender, spender, value);
        //returns true so you can see if the transaction went through or not
        return true;
    }
}