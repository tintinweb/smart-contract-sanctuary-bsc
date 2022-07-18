//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 */
contract Cloneable {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

}


interface IPresaleDatabase {
    function registerParticipation(address user, uint256 amount) external;
    function getOwner() external view returns (address);
    function startPresale(uint256 duration) external;
    function endPresale(uint256 amountRaised) external;
    function liquidityPairer() external view returns (address);
    function isWhitelisted(address user) external view returns (bool);
}

interface ILiquidityPairer {
    function pair(address projectToken, address backingToken, address DEX, address projectOwner) external;
}

contract PresaleData {

    // constants
    address internal constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Required Presale Initialization Data
    bool    public liquidityHasBeenAdded;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public minContribution;
    uint256 public maxContribution;
    uint256 public durationInBlocks;
    uint256 public presaleFinishedBlockNumber;
    uint256 public exchangeRate;  // 1 exchangeToken => n presaleTokens for user
    uint256 public liquidityRate; // 1 exchangeToken => n presaleTokens for liquidity
    address public exchangeToken; // token to accept for presale
    address public presaleOwner;
    address public presaleToken;

    // Presale Has Started
    bool public presaleStarted;
    bool public refundEnabled;

    // Presale Database For Fetching Dynamic Data Such As Fees And Fee Recipients
    IPresaleDatabase internal database;

    // DEX To Use
    address public DEX;

    // whitelist enabled
    bool public whitelistEnabled;

    // User -> Contribution
    struct User {
        uint256 contribution;
        uint256 toClaim;
        bool isWhitelisted;
    }
    mapping ( address => User ) public userInfo;

    // Token and backing tracking
    uint256 public totalValueRegistered; // Total Registered Contributions, Prevents selfdestruct() attacks
    uint256 public totalTokensToAllocate; // total tokens to give to users as rewards
    uint256 public valueRegisteredWhenEnded; // value registered when presale is ended

    modifier onlyOwner(){
        require(msg.sender == presaleOwner || msg.sender == database.getOwner(), 'Only Owner');
        _;
    }
}




contract Presale is PresaleData, Cloneable {

    /**
        Initializes The Proxy Contract
     */
    function __init__(
        uint softCap_,
        uint hardCap_,
        uint minContribution_,
        uint maxContribution_,
        uint durationInBlocks_,
        uint exchangeRate_,     // if set to zero, dynamically sets exchange rate based on funds generated
        uint liquidityRate_,    // if set to zero, dynamically sets liquidity rate based on funds generated
        address exchangeToken_, // BNB, BUSD, or something else -- matches token used for SoftCap, HardCap
        address presaleOwner_,
        address presaleToken_,
        address DEXToAddLiquidity,
        address database_
    ) external {
        require(
            presaleToken == address(0),
            'Presale Has Been Initialized'
        );
        require(
            presaleOwner_ != address(0) &&
            presaleToken_ != address(0) &&
            DEXToAddLiquidity != address(0),
            'Zero Address'
        );
        require(
            hardCap_ > 0 &&
            durationInBlocks_ > 0 &&
            maxContribution_ > 0,
            'Zero Inputs'
        );

        softCap = softCap_;
        hardCap = hardCap_;
        minContribution = minContribution_;
        maxContribution = maxContribution_;
        durationInBlocks = durationInBlocks_;
        exchangeRate = exchangeRate_;
        liquidityRate = liquidityRate_;
        exchangeToken = exchangeToken_;
        presaleOwner = presaleOwner_;
        presaleToken = presaleToken_; // add some bep20 validation like decimals()
        database = IPresaleDatabase(database_);
        DEX = DEXToAddLiquidity;
    }

    ///////////////////////////////////////
    ///////    PUBLIC FUNCTIONS    ////////
    ///////////////////////////////////////

    function register() external payable {
        require(
            exchangeToken == WETH,
            'Only Works For WETH'
        );
        _register(msg.sender, msg.value);
    }

    function register(uint256 amount) external {
        require(
            exchangeToken != WETH,
            'Only Works For Non WETH'
        );
        // transfer in tokens, noting amount received
        uint before = IERC20(exchangeToken).balanceOf(address(this));
        require(
            IERC20(exchangeToken).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On Transfer From'
        );
        uint received = IERC20(exchangeToken).balanceOf(address(this)) - before;
        require(
            received <= amount, 
            'Transfer Failure'
        );

        _register(msg.sender, received);
    }

    function claim() external {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            liquidityHasBeenAdded,
            'Liquidity Has Not Yet Been Added'
        );
        require(
            userInfo[msg.sender].contribution > 0,
            'Zero Contribution'
        );
        require(
            !refundEnabled,
            'Refund Is Enabled'
        );

        // amount to claim
        uint256 claimAmount = pendingClaim(msg.sender);
        
        // total value registered
        totalValueRegistered -= userInfo[msg.sender].contribution;

        // delete user data
        delete userInfo[msg.sender];

        // send claim to user
        _sendToken(presaleToken, msg.sender, claimAmount);
    }

    function claimRefund() external {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            totalValueRegistered < softCap || refundEnabled,
            'Soft Cap Has Been Reached'
        );
        uint256 contribution = userInfo[msg.sender].contribution;
        require(
            contribution > 0,
            'Zero To Refund'
        );
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Already Been Added'
        );

        // delete contribution for sender
        delete userInfo[msg.sender];

        // reduce tokens to allocate
        totalValueRegistered  -= contribution;

        // refund sender their backing
        _sendBacking(msg.sender, contribution);
    }

    receive() external payable {}

    ///////////////////////////////////////
    //////    INTERNAL FUNCTIONS    ///////
    ///////////////////////////////////////

    function _register(address user, uint256 value) internal {
        require(
            value > 0,
            'Cannot Register With Zero Value'
        );
        require(
            msg.sender == tx.origin,
            'Cannot Register A Proxy Or Contract'
        );
        require(
            timeLeftUntilExpiration() > 0,
            'Presale Has Expired'
        );
        require(
            presaleStarted,
            'Presale Has Not Started'
        );
        if (whitelistEnabled) {
            require(
                isWhiteListed(user),
                'Sender Not Whitelisted'
            );
        }

        // register purchase in database
        database.registerParticipation(user, value);

        // add value to contributors and total
        userInfo[user].contribution += value;
        totalValueRegistered += value;

        // increment number of tokens user can claim
        uint256 tokensToAllocate = ( value * exchangeRate ) / 10**18;
        userInfo[user].toClaim += tokensToAllocate;
        totalTokensToAllocate += tokensToAllocate;

        // ensure requirements
        require(
            userInfo[user].contribution >= minContribution,
            'Minimum Contribution Not Met'
        );
        require(
            userInfo[user].contribution <= maxContribution,
            'Max Contribution Exceeded'
        );
        require(
            totalValueRegistered <= hardCap,
            'Hard Cap Exceeded'
        );
    }

    function _sendToken(address token, address to, uint val) internal {
        require(
            IERC20(token).transfer(
                to,
                val
            ),
            'Failure On Token Transfer'
        );
    }

    function _sendBacking(address to, uint val) internal {
        if (exchangeToken == WETH) {
            (bool s,) = payable(to).call{value: val}("");
            require(s, 'Failure On ETH Transfer');
        } else {
            _sendToken(exchangeToken, to, val);
        }
    }


    ///////////////////////////////////////
    ////////    READ FUNCTIONS    /////////
    ///////////////////////////////////////

    function timeLeftUntilExpiration() public view returns (uint256) {
        return presaleFinishedBlockNumber > block.number ? presaleFinishedBlockNumber - block.number : 0;
    }

    function presaleTokenBalance() public view returns (uint256) {
        return IERC20(presaleToken).balanceOf(address(this));
    }

    function isDynamic() public view returns (bool) {
        return exchangeRate == 0 || liquidityRate == 0;
    }

    function isWhiteListed(address user) public view returns (bool) {
        return userInfo[user].isWhitelisted || database.isWhitelisted(user);
    }

    function userContribution(address user) external view returns (uint256) {
        return userInfo[user].contribution;
    }

    function pendingClaim(address user) public view returns (uint256) {
        if (userInfo[user].contribution == 0) {
            return 0;
        }
        
        if (isDynamic()) {
            if (liquidityHasBeenAdded) {
                return ( userInfo[msg.sender].contribution * presaleTokenBalance() ) / totalValueRegistered;
            } else {
                return ( userInfo[msg.sender].contribution * presaleTokenBalance() ) / ( 2 * totalValueRegistered );
            }
        }
        return userInfo[user].toClaim;
    }

    function tokensRequiredToStart() public view returns (uint256) {
        uint hCapMax = ( hardCap * exchangeRate ) / 10**18;
        uint liquidityMax = ( hardCap * liquidityRate ) / 10**18;
        return hCapMax + liquidityMax;
    }

    function tokensForLiquidity() internal view returns (uint256) {
        if (isDynamic()) {
            return presaleTokenBalance() / 2;
        } else {
            return ( totalValueRegistered * liquidityRate ) / 10**18;
        }
    }

    function launchPrice() public view returns (uint256) {
        if (isDynamic()) {
            uint tForLiquidity = liquidityHasBeenAdded ? presaleTokenBalance() : presaleTokenBalance() / 2;
            return ( totalValueRegistered * 10**18 ) / tForLiquidity;
        } else {
            return 10**36 / liquidityRate;
        }
    }

    ///////////////////////////////////////
    ////////    OWNER FUNCTIONS    ////////
    ///////////////////////////////////////

    function disableWhitelist() external onlyOwner {
        whitelistEnabled = false;
    }

    function whitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            userInfo[users[i]].isWhitelisted = true;
        }
        if (!whitelistEnabled) {
            whitelistEnabled = true;
        }
    }

    function unWhitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            userInfo[users[i]].isWhitelisted = false;
        }
    }

    function enableRefund() external onlyOwner {
        refundEnabled = true;
    }

    function end() external onlyOwner {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            totalValueRegistered >= softCap,
            'Soft Cap Has Not Been Reached'
        );
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Already Been Added'
        );

        // add liquidity to true
        liquidityHasBeenAdded = true;

        // set value registered to current balance
        valueRegisteredWhenEnded = totalValueRegistered;

        // send assets to Pairer and Pair Them
        address pairer = database.liquidityPairer();
        if (pairer != address(0)) {
            
            // transfer presale tokens to presale
            IERC20(presaleToken).transfer(pairer, tokensForLiquidity());

            // send backing asset to pairer
            _sendBacking(
                pairer, 
                exchangeToken == WETH ? address(this).balance : IERC20(exchangeToken).balanceOf(address(this))
            );

            // call function to pair liquidity between tokens
            ILiquidityPairer(pairer).pair(presaleToken, exchangeToken, DEX, presaleOwner);
        }

        // end presale in database
        database.endPresale(totalValueRegistered);

        // presale tokens left in contract
        if (isDynamic() == false) {
            uint256 remainingBalance = presaleTokenBalance();
            if (remainingBalance > totalTokensToAllocate) {
                _sendToken(
                    presaleToken, 
                    presaleOwner, 
                    remainingBalance - totalTokensToAllocate
                );
            }
        }
    }

    function start() external onlyOwner {
        require(
            presaleTokenBalance() >= tokensRequiredToStart(),
            'Tokens QTY Needed Are Not In Contract'
        );

        // start sale and set ending block number
        presaleStarted = true;
        presaleFinishedBlockNumber = block.number + durationInBlocks;
        
        // start presale in database
        database.startPresale(durationInBlocks * 3);
    }
}