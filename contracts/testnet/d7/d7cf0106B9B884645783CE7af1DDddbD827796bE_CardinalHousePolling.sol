// SPDX-License-Identifier: MIT
 
pragma solidity >=0.8.0 <0.9.0;

import "Ownable.sol";
import "CardinalToken.sol";

/**
 * @title Cardinal House Polling
 * @dev Contract that allows members to vote on various aspects of Cardinal House through a poll
 */
contract CardinalHousePolling is Ownable {

    // Struct containing all necessary information for a single proposal in a poll.
    struct Proposal {
        string name;
        uint voteCount;
    }

    // Struct containing all necessary information to store past proposals and their results.
    struct PastPoll {
        string title;
        string winningProposal;
        uint numProposals;
        mapping(uint => Proposal) proposals;    // Structs can't have arrays inside of them, so use a mapping like an array.
    }

    // References the deployed Cardinal Token.
    CardinalToken public cardinalToken;
 
    // Maps wallet addresses to a bool representing if they already voted in the current poll.
    mapping(address => bool) public voted;

    // List of proposals for the current poll.
    Proposal[] public proposals;

    // The number of polls that have already taken place.
    uint256 public numPastPolls = 0;

    // Mapping that acts as an array to store previous proposal data.
    mapping(uint256 => PastPoll) public pastPolls;

    // The title of the current poll.
    string public currPollTitle;

    // Array of wallet addresses for voters in the current poll.
    address[] public voters;

    // Boolean representing if voting is open for the current poll.
    bool public votingOpen = false;

    // Events for the polling smart contract.
    event PollOpened(string indexed pollTitle, string[] proposalNames);
    event PollClosed(string indexed pollTitle);
    event Vote(address indexed voter, string indexed pollTitle, string indexed proposal, uint numVotes);
 
    // Sets the reference to the contract address for the Cardinal Token with the poll contract is deployed.
    constructor(address payable CardinalTokenAddress) {
        cardinalToken = CardinalToken(CardinalTokenAddress);
    }
 
    /**
    * @dev Only owner function to create a new poll for the community.
    * @param pollTitle The title of the new poll.
    * @param proposalNames String array containing the names of all proposals for the new poll.
    */
    function createNewPoll(string memory pollTitle, string[] memory proposalNames) public onlyOwner { 
        // All voters have now not voted.
        for (uint256 i = 0; i < voters.length; i++) {
            voted[voters[i]] = false;
        }

        delete voters;
        delete proposals;
 
        // Adds all proposals to the new poll.
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }

        currPollTitle = pollTitle;
        votingOpen = true;

        emit PollOpened(pollTitle, proposalNames);
    }

    /**
    * @dev Only owner function to close the poll and add it to the list of previous polls.
    */
    function closePoll() public onlyOwner {
        require(votingOpen, "There isn't a poll to close currently.");

        votingOpen = false;
        
        string memory currentWinningProposalName = winningProposalName();

        // Creates the PastPoll struct to store the closing poll data.
        PastPoll storage nextPastPoll = pastPolls[numPastPolls++];
        nextPastPoll.title = currPollTitle;
        nextPastPoll.winningProposal = currentWinningProposalName;
        nextPastPoll.numProposals = proposals.length;

        // Adds all closing poll proposals to the PastPoll struct.
        for (uint i = 0; i < proposals.length; i++) {
            nextPastPoll.proposals[i] = Proposal({
                name: proposals[i].name,
                voteCount: proposals[i].voteCount
            });
        }

        emit PollClosed(currPollTitle);
    }

    /**
    * @dev Voting function that allows a user to vote in the current poll.
    * @param proposal The index of the proposal in the poll's proposal array.
    */
    function vote(uint proposal) public {
        require(votingOpen, "There isn't a poll going on currently.");
        require(!voted[msg.sender], "You have already voted in this poll.");
        require(proposal >= 0, "Your proposal number is invalid.");
        require(proposal < proposals.length, "There aren't that many proposals, pick a smaller number.");

        uint256 voterCRNLBalance = cardinalToken.balanceOf(msg.sender);
        require(voterCRNLBalance > 0, "You need Cardinal Tokens to be able to vote.");
 
        voters.push(msg.sender);
        voted[msg.sender] = true;

        // This can also be updated so that it's one vote per address not one per Cardinal Token the user holds.
        proposals[proposal].voteCount += voterCRNLBalance;

        emit Vote(msg.sender, currPollTitle, proposals[proposal].name, voterCRNLBalance);
    }
 
    /**
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }
 
    /**
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return _winningProposalName the name of the winner
    */
    function winningProposalName() public view returns (string memory _winningProposalName) {
        _winningProposalName = proposals[winningProposal()].name;
    }

    /**
     * @dev Gets the number of proposals in the current poll.
     * @return numProposals the number of proposals in the current poll.
    */
    function getNumberOfProposals() public view returns (uint numProposals) {
        return proposals.length;
    }

    /**
     * @dev Gets a single proposal from a previous poll.
     * @param pastPollIndex The index of the previous poll in the pastPolls array.
     * @param proposalIndex The index of the proposal in the previous poll's proposal array.
     * @return proposal the proposal from the previous poll.
    */
    function getPastProposal(uint pastPollIndex, uint proposalIndex) public view returns (Proposal memory proposal) {
        proposal = pastPolls[pastPollIndex].proposals[proposalIndex];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
 
pragma solidity >=0.8.0 <0.9.0;
 
import "ERC20.sol";
import "Ownable.sol";
import "Uniswap.sol";

/**
 * @title Cardinal House Token
 * @dev Token contract for the Cardinal House ecosystem currency
 */
contract CardinalToken is ERC20, Ownable {

    // Mapping to exclude some contracts from fees. Transfers are excluded from fees if address in this mapping is recipient or sender.
    mapping (address => bool) public excludedFromFees;

    // Blacklist mapping to prevent addresses from trading if necessary (i.e. flagged for malicious activity).
    mapping (address => bool) public blacklist;

    // Mapping to determine which addresses can mint Cardinal Tokens for bridging.
    mapping (address => bool) public minters;

    // Address of the contract for burning Cardinal Tokens.
    address public burnWalletAddress;

    // Liquidity wallet address used to hold 30% of the Cardinal Tokens for the liquidity pool.
    // After these tokens are moved to the DEX, this address will no longer be used.
    address public liquidityWalletAddress;

    // Address of the Cardinal Token presale contract.
    address public preSaleAddress;

    // Wallet address used for the Cardinal Token member giveaways.
    address payable public memberGiveawayWalletAddress;

    // Marketing wallet address used for funding marketing.
    address payable public marketingWalletAddress;

    // Developer wallet address used for funding the team.
    address payable public developerWalletAddress;

    // The DEX router address for swapping Cardinal Tokens for Matic.
    address public uniswapRouterAddress;

    // Member giveaway transaction fee - deployed at 2%.
    uint256 public memberGiveawayFeePercent = 2;

    // Marketing transaction fee - deployed at 2%.
    uint256 public marketingFeePercent = 2;

    // Developer team transaction fee - deployed at 1%.
    uint256 public developerFeePercent = 1;

    // DEX router interface.
    IUniswapV2Router02 private uniswapRouter;

    // Address of the Matic to Cardinal Token pair on the DEX.
    address public uniswapPair;

    // Determines how many Cardinal Tokens this contract needs before it swaps for Matic to pay fee wallets.
    uint256 public contractTokenDivisor = 1000;

    // Events to emit when the transaction fees are updated
    event memberGiveawayTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event marketingTransactionFeeUpdated(uint256 indexed transactionFeeAmount);
    event developerTransactionFeeUpdated(uint256 indexed transactionFeeAmount);

    // Initial token distribution:
    // 35% - Pre-sale
    // 35% - Liquidity pool (6 month lockup period)
    // 10% - Marketing
    // 20% - Developer coins (6 month lockup period)
    constructor(
        uint256 initialSupply,
        address _preSaleAddress, 
        address _burnWalletAddress,
        address _liquidityWalletAddress,
        address payable _memberGiveawayWalletAddress,
        address payable _marketingWalletAddress,
        address payable _developerWalletAddress,
        address _uniswapRouterAddress) ERC20("CardinalToken", "CRNL") {
            preSaleAddress = _preSaleAddress;
            memberGiveawayWalletAddress = _memberGiveawayWalletAddress;
            burnWalletAddress = _burnWalletAddress;
            liquidityWalletAddress = _liquidityWalletAddress;
            marketingWalletAddress = _marketingWalletAddress;
            developerWalletAddress = _developerWalletAddress;
            uniswapRouterAddress = _uniswapRouterAddress;

            excludedFromFees[memberGiveawayWalletAddress] = true;
            excludedFromFees[developerWalletAddress] = true;
            excludedFromFees[marketingWalletAddress] = true;
            excludedFromFees[liquidityWalletAddress] = true;
            excludedFromFees[preSaleAddress] = true;

            _mint(preSaleAddress, ((initialSupply) * 35 / 100));
            _mint(liquidityWalletAddress, ((initialSupply) * 35 / 100));
            _mint(marketingWalletAddress, initialSupply / 10);
            _mint(developerWalletAddress, initialSupply / 5);

            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouterAddress);
            uniswapRouter = _uniswapV2Router;
            _approve(address(this), address(uniswapRouter), initialSupply);
            uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            IERC20(uniswapPair).approve(address(uniswapRouter), type(uint256).max);
    }

    /**
     * @dev Returns the contract address
     * @return contract address
     */
    function getContractAddress() public view returns (address){
        return address(this);
    }

    /**
    * @dev Adds a user to be excluded from fees.
    * @param user address of the user to be excluded from fees.
     */
    function excludeUserFromFees(address user) public onlyOwner {
        excludedFromFees[user] = true;
    }

    /**
    * @dev Gets the current timestamp, used for testing + verification
    * @return the the timestamp of the current block
     */
    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    /**
    * @dev Removes a user from the fee exclusion.
    * @param user address of the user than will now have to pay transaction fees.
     */
    function includeUsersInFees(address user) public onlyOwner {
        excludedFromFees[user] = false;
    }

    /**
     * @dev Overrides the BEP20 transfer function to include transaction fees.
     * @param recipient the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklist[_msgSender()], "You have been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklist[recipient], "The address you are trying to send Cardinal Tokens to has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");

        // Stops investors from owning more than 2% of the total supply from purchasing Cardinal Tokens from the DEX.
        if (_msgSender() == uniswapPair && !excludedFromFees[_msgSender()] && !excludedFromFees[recipient]) {
            require((balanceOf(recipient) + amount) < (totalSupply() / 166), "You can't have more than 2% of the total Cardinal Token supply after a DEX swap.");
        }

        // If the sender or recipient is excluded from fees, perform the default transfer.
        if (excludedFromFees[_msgSender()] || excludedFromFees[recipient]) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        // Member giveaway transaction fee.
        uint256 memberGiveawayFee = (amount * memberGiveawayFeePercent) / 100;
        // Marketing team transaction fee.
        uint256 marketingFee = (amount * marketingFeePercent) / 100;
        // Developer team transaction fee.
        uint256 developerFee = (amount * developerFeePercent) / 100;

        // The total fee to send to the contract address (marketing + development).
        uint256 contractFee = marketingFee + developerFee;
 
        // Sends the transaction fees to the giveaway wallet and contract address
        _transfer(_msgSender(), memberGiveawayWalletAddress, memberGiveawayFee);
        _transfer(_msgSender(), address(this), contractFee);

        uint256 contractCardinalTokenBalance = balanceOf(address(this));

        if (_msgSender() != uniswapPair) {
            if (contractCardinalTokenBalance > balanceOf(uniswapPair) / contractTokenDivisor) {
                swapCardinalTokensForMatic(contractCardinalTokenBalance);
            }
                
            uint256 contractMaticBalance = address(this).balance;
            if (contractMaticBalance > 0) {
                sendFeesToWallets(address(this).balance);
            }
        }
 
        // Sends [initial amount] - [fees] to the recipient
        uint256 valueAfterFees = amount - contractFee - memberGiveawayFee;
        _transfer(_msgSender(), recipient, valueAfterFees);
        return true;
    }

    /**
     * @dev Overrides the BEP20 transferFrom function to include transaction fees.
     * @param from the address from where the tokens are coming from
     * @param to the recipient of the transfer
     * @param amount the amount to be transfered
     * @return bool representing if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        // Ensure the sender isn't blacklisted.
        require(!blacklist[_msgSender()], "You have been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the address where the tokens are coming from isn't blacklisted.
        require(!blacklist[from], "The address you're trying to spend the Cardinal Tokens from has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");
        // Ensure the recipient isn't blacklisted.
        require(!blacklist[to], "The address you are trying to send Cardinal Tokens to has been blacklisted from trading the Cardinal Token. If you think this is an error, please contact the Cardinal House team.");

        // If the from address or to address is excluded from fees, perform the default transferFrom.
        if (excludedFromFees[from] || excludedFromFees[to] || excludedFromFees[_msgSender()]) {
            _spendAllowance(from, _msgSender(), amount);
            _transfer(from, to, amount);
            return true;
        }

        // Member giveaway transaction fee.
        uint256 memberGiveawayFee = (amount * memberGiveawayFeePercent) / 100;
        // Marketing team transaction fee.
        uint256 marketingFee = (amount * marketingFeePercent) / 100;
        // Developer team transaction fee.
        uint256 developerFee = (amount * developerFeePercent) / 100;

        // The total fee to send to the contract address (marketing + development).
        uint256 contractFee = marketingFee + developerFee;
 
        // Sends the transaction fees to the giveaway wallet and contract address
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, memberGiveawayWalletAddress, memberGiveawayFee);
        _transfer(from, address(this), contractFee);

        uint256 contractCardinalTokenBalance = balanceOf(address(this));

        if (_msgSender() != uniswapPair) {
            if (contractCardinalTokenBalance > balanceOf(uniswapPair) / contractTokenDivisor) {
                swapCardinalTokensForMatic(contractCardinalTokenBalance);
            }
                
            uint256 contractMaticBalance = address(this).balance;
            if (contractMaticBalance > 0) {
                sendFeesToWallets(address(this).balance);
            }
        }
 
        // Sends [initial amount] - [fees] to the recipient
        uint256 valueAfterFees = amount - contractFee - memberGiveawayFee;
        _transfer(from, to, valueAfterFees);
        return true;
    }

    /**
     * @dev Swaps Cardinal Tokens from transaction fees to Matic.
     * @param amount the amount of Cardinal Tokens to swap
     */
    function swapCardinalTokensForMatic(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        _approve(address(this), address(uniswapRouter), amount);
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Sends Matic to transaction fee wallets after Cardinal Token swaps.
     * @param amount the amount to be transfered
     */
    function sendFeesToWallets(uint256 amount) private {
        uint256 totalFee = marketingFeePercent + developerFeePercent;
        marketingWalletAddress.transfer((amount * marketingFeePercent) / totalFee);
        developerWalletAddress.transfer((amount * developerFeePercent) / totalFee);
    }

    /**
     * @dev Sends Matic to transaction fee wallets manually as opposed to happening automatically after a certain level of volume
     */
    function disperseFeesManually() public onlyOwner {
        uint256 contractMaticBalance = address(this).balance;
        sendFeesToWallets(contractMaticBalance);
    }

    /**
     * @dev Swaps all Cardinal Tokens in the contract for Matic and then disperses those funds to the transaction fee wallets.
     * @param amount the amount of Cardinal Tokens in the contract to swap for Matic
     * @param useAmount boolean to determine if the amount sent in is swapped for Matic or if the entire contract balance is swapped.
     */
    function swapCardinalTokensForMaticManually(uint256 amount, bool useAmount) public onlyOwner {
        if (useAmount) {
            swapCardinalTokensForMatic(amount);
        }
        else {
            uint256 contractCardinalTokenBalance = balanceOf(address(this));
            swapCardinalTokensForMatic(contractCardinalTokenBalance);
        }

        uint256 contractMaticBalance = address(this).balance;
        sendFeesToWallets(contractMaticBalance);
    }

    receive() external payable {}

    /**
     * @dev Sets the value that determines how many Cardinal Tokens need to be in the contract before it's swapped for Matic.
     * @param newDivisor the new divisor value to determine the swap threshold
     */
    function setContractTokenDivisor(uint256 newDivisor) public onlyOwner {
        contractTokenDivisor = newDivisor;
    }

    /**
    * @dev Updates the blacklist mapping for a given address
    * @param user the address that is being added or removed from the blacklist
    * @param blacklisted a boolean that determines if the given address is being added or removed from the blacklist
    */
    function updateBlackList(address user, bool blacklisted) public onlyOwner {
        blacklist[user] = blacklisted;
    }

    /**
    * @dev Function to update the member giveaway transaction fee - can't be more than 5 percent
    * @param newMemberGiveawayTransactionFee the new member giveaway transaction fee
    */
    function updateMemberGiveawayTransactionFee(uint256 newMemberGiveawayTransactionFee) public onlyOwner {
        require(newMemberGiveawayTransactionFee <= 5, "The member giveaway transaction fee can't be more than 5%.");
        memberGiveawayFeePercent = newMemberGiveawayTransactionFee;
        emit memberGiveawayTransactionFeeUpdated(newMemberGiveawayTransactionFee);
    }

    /**
    * @dev Function to update the marketing transaction fee - can't be more than 5 percent
    * @param newMarketingTransactionFee the new marketing transaction fee
    */
    function updateMarketingTransactionFee(uint256 newMarketingTransactionFee) public onlyOwner {
        require(newMarketingTransactionFee <= 5, "The marketing transaction fee can't be more than 5%.");
        marketingFeePercent = newMarketingTransactionFee;
        emit marketingTransactionFeeUpdated(newMarketingTransactionFee);
    }

    /**
    * @dev Function to update the developer transaction fee - can't be more than 5 percent
    * @param newDeveloperTransactionFee the new developer transaction fee
    */
    function updateDeveloperTransactionFee(uint256 newDeveloperTransactionFee) public onlyOwner {
        require(newDeveloperTransactionFee <= 5, "The developer transaction fee can't be more than 5%.");
        developerFeePercent = newDeveloperTransactionFee;
        emit developerTransactionFeeUpdated(newDeveloperTransactionFee);
    }

    /**
    * @dev Function to add or remove a Cardinal Token minter
    * @param user the address that will be added or removed as a minter
    * @param isMinter boolean representing if the address provided will be added or removed as a minter
    */
    function updateMinter(address user, bool isMinter) public onlyOwner {
        minters[user] = isMinter;
    }

    /**
    * @dev Minter only function to mint new Cardinal Tokens for bridging
    * @param user the address that the tokens will be minted to
    * @param amount the amount of tokens to be minted to the user
    */
    function mint(address user, uint256 amount) public {
        require(minters[_msgSender()], "You are not authorized to mint Cardinal Tokens.");
        _mint(user, amount);
    }

    /**
    * @dev Minter only function to burn Cardinal Tokens for bridging and deflation upon service purchases with the Cardinal Token
    * @param user the address to burn the tokens from
    * @param amount the amount of tokens to be burned
    */
    function burn(address user, uint256 amount) public {
        require(minters[_msgSender()], "You are not authorized to burn Cardinal Tokens.");
        _burn(user, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}