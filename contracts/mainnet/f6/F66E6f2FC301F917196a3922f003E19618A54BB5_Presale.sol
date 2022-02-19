/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// File: @openzeppelin\contracts\utils\Context.sol

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

// File: @openzeppelin\contracts\security\Pausable.sol

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File: @chainlink\contracts\src\v0.8\interfaces\AggregatorV3Interface.sol

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin\contracts\interfaces\IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

// File: contracts\Presale.sol


//import "./BrnMetaverse.sol";
/**
 * @title TokenPresale
 * TokenPresale allows investors to make
 * token purchases and assigns them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */

contract Presale is Pausable, Ownable {
    /**
     * crowdsale constructor
     * @param _wallet who receives invested ether
     * @param _cap above which the crowdsale is closed
     */

    constructor(
        address _priceFeedAddress,
        address _tokenAddress,
        address payable _wallet,
        uint256 _cap // 50,000,000 BRN
    ) {
        require(_wallet != address(0));
        require(_tokenAddress != address(0));
        require(_priceFeedAddress != address(0));
        require(_cap > 0);
        TokenAddress = _tokenAddress;
        priceFeedAddress = _priceFeedAddress;

        wallet = _wallet;
        cap = _cap * (10**18); //cap in tokens base units (=1000000 tokens)
        phase1Cap = (cap * 14) / 100;
        phase2Cap = (cap * 36) / 100;
        phase3Cap = (cap * 50) / 100;
    }

    // Mapping of whitelisted users.
    mapping(address => bool) public whitelist;

    mapping(address => uint256) public phase1Balance;
    mapping(address => uint256) public phase2Balance;
    mapping(address => uint256) public phase3Balance;

    mapping(address => uint256) public phase1USDAmount;
    mapping(address => uint256) public phase2USDAmount;
    mapping(address => uint256) public phase3USDAmount;

    mapping(address => uint256) public Contribution;

    address priceFeedAddress;

    uint256 public phase1Start = 0;
    uint256 public phase2Start = 0;
    uint256 public phase3Start = 0;
    uint256 public presaleEnd = 0;

    // The token being sold
    address immutable TokenAddress;

    // address where funds are collected
    address public wallet;

    //amount of wei raised 
    uint256 public weiRaised; 

    // amount of tokens sold in each phase
    uint256 public tokenSoldPhase1;
    uint256 public tokenSoldPhase2;
    uint256 public tokenSoldPhase3;

    // cap above which the crowdsale is ended
    uint256 public cap;
    uint256 public phase1Cap;
    uint256 public phase2Cap;
    uint256 public phase3Cap;

    string public contactInformation;

    /**
     * event for token purchase logging
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

    event TokenWithdrawal(address indexed beneficiary, uint256 amount);

    function startNextPhase() external onlyOwner {
        if (phase1Start == phase2Start && phase3Start == phase2Start) {
            phase1Start = block.timestamp;
            phase2Start = phase1Start + 24 weeks;
            phase3Start = phase2Start + 16 weeks;
            presaleEnd = phase3Start + 8 weeks;
        } else if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            require(
                tokenSoldPhase1 == phase1Cap,
                "Phase 1 cap has not been exhausted"
            );
            phase2Start = block.timestamp;
        } else if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            require(
                tokenSoldPhase2 == phase2Cap,
                "Phase 2 cap has not been exhausted"
            );
            phase3Start = block.timestamp;
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            require(
                tokenSoldPhase3 == phase3Cap,
                "Phase 2 cap has not been exhausted"
            );
            presaleEnd = block.timestamp;
        }
    }

    /**
     * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
     */
    modifier isWhitelisted(address _beneficiary) {
        require(whitelist[_beneficiary]);
        _;
    }

    /**
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
     * @param _beneficiaries Addresses to be added to the whitelist
     */
    function addManyToWhitelist(address[] memory _beneficiaries)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    /**
     * @dev Adds single address to whitelist.
     * @param _beneficiary Address to be added to the whitelist
     */
    function addToWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = true;
    }

    /**
     * @dev Removes single address from whitelist.
     * @param _beneficiary Address to be removed to the whitelist
     */
    function removeFromWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = false;
    }

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen() {
        // solium-disable-next-line security/no-block-members
        require(
            block.timestamp >= phase1Start && block.timestamp <= presaleEnd
        );
        _;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function phase1HasClosed() public view returns (bool) {
        return block.timestamp > phase2Start;
    }

    function phase2HasClosed() public view returns (bool) {
        return block.timestamp > phase2Start;
    }

    function presaleHasClosed() public view returns (bool) {
        return block.timestamp > presaleEnd;
    }

    function getPrice() public view returns (uint256, uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());
        return (uint256(price), decimals);
    }

    function coinToUSD(uint256 _amountIn) public view returns (uint256) {
        (uint256 inputTokenPrice, uint256 inputTokenDecimals) = getPrice();
        uint256 value2USD = (_amountIn * inputTokenPrice) /
            10**inputTokenDecimals;
        return value2USD;
    }

    // fallback function to buy tokens
    receive() external payable {
        buyTokens(msg.sender);
    }

    function getPhaseArg()
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 phaseCap;
        uint256 tokensSold;
        uint256 pricePerToken;
        if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            phaseCap = phase1Cap;
            tokensSold = tokenSoldPhase1;
            pricePerToken = 10 * 10**18;
        }
        if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            phaseCap = phase2Cap;
            tokensSold = tokenSoldPhase2;
            pricePerToken = 20 * 10**18;
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            phaseCap = phase3Cap;
            tokensSold = tokenSoldPhase3;
            pricePerToken = 30 * 10**18;
        }
        return (phaseCap, tokensSold, pricePerToken);
    }

    /**
     * Low level token purchse function
     * @param beneficiary will recieve the tokens.
     */
    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        onlyWhileOpen
    {
        require(!presaleHasClosed(), "The presale is over");
        require(beneficiary != address(0));
        require(msg.value > 0);

        uint256 amount = coinToUSD(msg.value);

        uint256 phaseUSDAmount;

        if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            phaseUSDAmount = phase1USDAmount[beneficiary];
        }
        if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            phaseUSDAmount = phase2USDAmount[beneficiary];
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            phaseUSDAmount = phase3USDAmount[beneficiary];
        }

        require(amount >= 10 * 10**18, "The enter amount is below minimum");
        require(amount <= 10000 * 10**18, "The enter amount is above maximum");
        require(
            amount + phaseUSDAmount <= 10000 * 10**18,
            "Your total purchase will be above the allowable maximum per wallet!"
        );

        (
            uint256 phaseCap,
            uint256 tokensSold,
            uint256 pricePerToken
        ) = getPhaseArg();

        uint256 tokenAmount = (amount * 100 * 10**18) / pricePerToken;
        require(tokenAmount + tokensSold <= phaseCap, "Greater than phase cap");

        if (block.timestamp > phase1Start && block.timestamp < phase2Start) {
            phase1USDAmount[beneficiary] += amount;
            phase1Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase1 += tokenAmount;
        }
        if (block.timestamp > phase2Start && block.timestamp < phase3Start) {
            phase2USDAmount[beneficiary] += amount;
            phase2Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase2 += tokenAmount;
        }
        if (block.timestamp > phase3Start && block.timestamp < presaleEnd) {
            phase3USDAmount[beneficiary] += amount;
            phase3Balance[beneficiary] += tokenAmount;
            Contribution[beneficiary] += msg.value;
            tokenSoldPhase3 += tokenAmount;
        }

        uint256 weiAmount = msg.value;
        // update weiRaised
        weiRaised = weiRaised + weiAmount;

        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
        forwardFunds();
    }

    // withdraw ERC20 Tokens
    function withdrawToken() public whenNotPaused isWhitelisted(msg.sender) {
        require(
            presaleHasClosed() || phase1HasClosed() || phase2HasClosed(),
            "All presale phases are still on is still on"
        );
        uint256 balance;
        if (presaleHasClosed()) {
            balance =
                phase1Balance[msg.sender] +
                phase2Balance[msg.sender] +
                phase3Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
            phase2Balance[msg.sender] = 0;
            phase3Balance[msg.sender] = 0;
        } else if (phase2HasClosed()) {
            balance = phase1Balance[msg.sender] + phase2Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
            phase2Balance[msg.sender] = 0;
        } else if (phase1HasClosed()) {
            balance = phase1Balance[msg.sender];
            phase1Balance[msg.sender] = 0;
        }
        IERC20(TokenAddress).transfer(msg.sender, balance);
        emit TokenWithdrawal(msg.sender, balance);
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        payable(wallet).transfer(msg.value);
    }

    function setContactInformation(string memory info) public onlyOwner {
        contactInformation = info;
    }
}