//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IPresaleDatabase.sol";
import "./Cloneable.sol";
import "./IERC20.sol";

interface ILiquidityPairer {
    function pair(address projectToken, address backingToken, address DEX) external;
}

contract PresaleData {

    // Has Liquidity Been Provided yet?
    bool public liquidityHasBeenAdded;

    // block presale is finished
    uint256 public presaleFinishedBlockNumber;
   
    // Presale Has Started
    bool public presaleStarted;
    bool public refundEnabled;

    // Presale Database For Fetching Dynamic Data Such As Fees And Fee Recipients
    IPresaleDatabase internal database;

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
        require(
            database.isOwner(msg.sender, address(this)),
            'Only Owner'
        );
        _;
    }
}

contract Presale is PresaleData, Cloneable {

    /**
        Only To Be Called After Deployment From Database
     */
    function init() external {
        require(address(database) == address(0), 'Already Paired');
        database = IPresaleDatabase(msg.sender);
    }


    ///////////////////////////////////////
    ///////    PUBLIC FUNCTIONS    ////////
    ///////////////////////////////////////

    function register() external payable {
        require(
            isWETH(),
            'Only WETH'
        );
        _register(msg.sender, msg.value);
    }

    function register(uint256 amount) external {
        require(
            !isWETH(),
            'Only Non WETH'
        );

        // transfer in tokens, noting amount received
        uint before = backingTokenBalance();
        require(
            IERC20(backingToken()).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On Transfer From'
        );
        uint received = backingTokenBalance() - before;
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
        _sendToken(presaleToken(), msg.sender, claimAmount);
    }

    function claimRefund() external {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            refundEnabled,
            'Refund Not Enabled'
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

    receive() external payable {
        require(
            isWETH(),
            'Only WETH'
        );
        _register(msg.sender, msg.value);
    }

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
        uint256 tokensToAllocate = ( value * exchangeRate() ) / 10**18;
        userInfo[user].toClaim += tokensToAllocate;
        totalTokensToAllocate += tokensToAllocate;

        // ensure requirements
        require(
            userInfo[user].contribution >= minContribution(),
            'Minimum Contribution Not Met'
        );
        require(
            userInfo[user].contribution <= maxContribution(),
            'Max Contribution Exceeded'
        );
        require(
            totalValueRegistered <= hardCap(),
            'Hard Cap Exceeded'
        );
    }

    function _sendToken(address token, address to, uint val) internal {
        if (token == address(0) || to == address(0) || val == 0) {
            return;
        }
        require(
            IERC20(token).transfer(
                to,
                val
            ),
            'Failure On Token Transfer'
        );
    }

    function _sendBacking(address to, uint val) internal {
        if (isWETH()) {
            (bool s,) = payable(to).call{value: val}("");
            require(s, 'Failure On ETH Transfer');
        } else {
            _sendToken(backingToken(), to, val);
        }
    }


    ///////////////////////////////////////
    ////////    READ FUNCTIONS    /////////
    ///////////////////////////////////////

    function hardCap() public view returns (uint256) {
        return database.getHardCap(address(this));
    }

    function maxContribution() public view returns (uint256) {
        return database.getMaxContribution(address(this));
    }

    function minContribution() public view returns (uint256) {
        return database.getMinContribution(address(this));
    }

    function exchangeRate() public view returns (uint256) {
        return database.getExchangeRate(address(this));
    }

    function liquidityRate() public view returns (uint256) {
        return database.getLiquidityRate(address(this));
    }

    function duration() public view returns (uint256) {
        return database.getDuration(address(this));
    }

    function backingToken() public view returns (address) {
        return database.getBackingToken(address(this));
    }

    function presaleToken() public view returns (address) {
        return database.getPresaleToken(address(this));
    }

    function DEX() public view returns (address) {
        return database.getDEX(address(this));
    }

    function saleOwner() public view returns (address) {
        return database.getSaleOwner(address(this));
    }

    function isWETH() public view returns (bool) {
        return database.isWETH(address(this));
    }

    function timeLeftUntilExpiration() public view returns (uint256) {
        return presaleFinishedBlockNumber > block.number ? presaleFinishedBlockNumber - block.number : 0;
    }

    function presaleTokenBalance() public view returns (uint256) {
        return IERC20(presaleToken()).balanceOf(address(this));
    }

    function backingTokenBalance() public view returns (uint256) {
        return isWETH() ? address(this).balance : IERC20(backingToken()).balanceOf(address(this));
    }

    function isDynamic() public view returns (bool) {
        return database.isDynamic(address(this));
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
        uint hCapMax = ( hardCap() * exchangeRate() ) / 10**18;
        uint liquidityMax = ( hardCap() * liquidityRate() ) / 10**18;
        return hCapMax + liquidityMax;
    }

    function tokensForLiquidity() internal view returns (uint256) {
        if (isDynamic()) {
            return presaleTokenBalance() / 2;
        } else {
            return ( totalValueRegistered * liquidityRate() ) / 10**18;
        }
    }

    function launchPrice() public view returns (uint256) {
        if (isDynamic()) {
            uint tForLiquidity = liquidityHasBeenAdded ? presaleTokenBalance() : presaleTokenBalance() / 2;
            return ( totalValueRegistered * 10**18 ) / tForLiquidity;
        } else {
            return 10**36 / liquidityRate();
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
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Been Added'
        );
        refundEnabled = true;
        database.endPresale(totalValueRegistered);
        
        _sendToken(
            presaleToken(), 
            saleOwner(), 
            presaleTokenBalance()
        );
    }

    function end() external onlyOwner {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Already Been Added'
        );
        require(
            refundEnabled == false,
            'Refund Has Been Enabled'
        );
        require(
            totalValueRegistered > 0,
            'Enable Refund Instead'
        );

        // add liquidity to true
        liquidityHasBeenAdded = true;

        // set value registered to current balance
        valueRegisteredWhenEnded = totalValueRegistered;

        // Presale Token
        address token = presaleToken();

        // send assets to Pairer and Pair Them
        address pairer = database.liquidityPairer();
        if (pairer != address(0)) {
            
            // transfer presale tokens to presale
            IERC20(token).transfer(pairer, tokensForLiquidity());

            // send backing asset to pairer
            _sendBacking(
                pairer, 
                backingTokenBalance()
            );

            // call function to pair liquidity between tokens
            ILiquidityPairer(pairer).pair(token, backingToken(), DEX());
        }

        // end presale in database
        database.endPresale(totalValueRegistered);

        // presale tokens left in contract
        if (isDynamic() == false) {
            uint256 remainingBalance = presaleTokenBalance();
            if (remainingBalance > totalTokensToAllocate) {
                _sendToken(
                    token, 
                    saleOwner(), 
                    remainingBalance - totalTokensToAllocate
                );
            }
        }
    }

    function start() external onlyOwner {
        require(
            presaleTokenBalance() >= tokensRequiredToStart(),
            'Token QTY Needed Are Not In Contract'
        );

        // start sale and set ending block number
        presaleStarted = true;
        presaleFinishedBlockNumber = block.number + duration();
        
        // start presale in database
        database.startPresale();
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IPresaleDatabase {
    function registerParticipation(address user, uint256 amount) external;
    function isOwner(address owner, address sale) external view returns (bool);
    function startPresale() external;
    function endPresale(uint256 amountRaised) external;
    function liquidityPairer() external view returns (address);
    function isWhitelisted(address user) external view returns (bool);
    function getHardCap(address sale) external view returns (uint256);
    function getMaxContribution(address sale) external view returns (uint256);
    function getMinContribution(address sale) external view returns (uint256);
    function getExchangeRate(address sale) external view returns (uint256);
    function getLiquidityRate(address sale) external view returns (uint256);
    function getDuration(address sale) external view returns (uint256);
    function getBackingToken(address sale) external view returns (address);
    function getPresaleToken(address sale) external view returns (address);
    function getDEX(address sale) external view returns (address);
    function isDynamic(address sale) external view returns (bool);
    function isWETH(address sale) external view returns (bool);
    function getSaleOwner(address sale) external view returns (address);
    function getFeeReceiver() external view returns (address);
    function getFee(address sale) external view returns (uint256);
    function isSale(address sale) external view returns (bool);
    function tokenLocker() external view returns (address);
    function getOwner() external view returns (address);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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