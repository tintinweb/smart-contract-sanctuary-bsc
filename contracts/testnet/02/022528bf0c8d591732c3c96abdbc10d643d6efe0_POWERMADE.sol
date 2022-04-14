// SPDX-License-Identifier: MIT

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *                    ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗                  
 *                    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║                  
 *                       ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║                  
 *                       ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║                  
 *                       ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║                  
 *                       ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝                  
 *                                                                                  
 */

// TESTNET VERSION V3

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./BEP20.sol";
import "./BEP20Snapshot.sol";
import "./IPancakeSwap.sol";
import "./LPLocker.sol";
import "./ReflectionManager.sol";
import "./AutomaticBuyback.sol";

contract POWERMADE is BEP20, BEP20Snapshot, Ownable {

    using SafeMath for uint256;

    IPancakeRouter02 public pancakeRouter;              // The DEX router
    address public pancakePair;                         // The liquidity pair
    mapping (address => bool) public automatedMarketMakerPairs;     // All the liquidity pairs (pancakePair included)
    bool private swapping;                              // Swapping flag (re-entrancy protection)
    uint256 public transactionsBeforeExecution = 10;    // Number of transactions before execution of the internal features (1 for every consecutive transaction)
    uint256 private tx_counter;
    uint256 private amountReflectionTax;
    uint256 private amountBuybackTax;
    uint256 private amountLiquidityTax;
    mapping (address => bool) private _isExcludedFromFees;      // Addresses excluded from the token tax
    mapping (address => bool) public multisenderSmartContract;  // Smart contracts or wallets used to send massive amount of tokens

    ReflectionManager public reflectionManager;         // The current (main) Reflection Manager
    ReflectionManager public reflectionManagerOld;      // Used if changing the reflection token
    BEP20 public reflectionToken;                       // The reflection token (BTCB)
    uint256 public gasForProcessing = 300000;           // Gas for processing the reflections

    AutomaticBuyback public automaticBuyback;           // The Automatic Buyback Manager
    BEP20 public automaticBuyback_cumulatedToken;       // The cumulated token for the buyback (BUSD)

    LPLocker public LP_locker;                          // The locker contract for the Automatic liquidity feature (destination of the LP)

    mapping(address => bool) private _isExcludedFromAntiWhale;
    uint256 public maxTransferAmountRate = 1000;    // default and minimum value will be 1000 / 1E6 = 0.001 (0.1% of the supply)
    bool private enableAntiwhale;                   // Limit max TX except BUY. Default disabled (false)
    mapping (address => bool) private _isTimelockExempt;    // Addresses excluded from Cooldown feature
    mapping (address => uint) private cooldownTimer;
    bool private cooldownEnabled;                    // Deadtime between trades on AMM. Default disabled (false)

    mapping(address => bool) private _isBlacklisted;     // Blacklist for compliance
    mapping(address => bool) private _canSnapshot;       // Wallet allowed to do snapshots

    // Constants
    uint256 public constant REFLECTION_ELIGIBILITY_THRESHOLD = 2000;        // Amount of PWD needed for the reflection
    uint256 public constant REFLECTION_TAX = 2;
    uint256 public constant BUYBACK_AND_BURN_TAX = 3;
    uint256 public constant AUTOMATED_LIQUIDITY_TAX = 3;
    uint256 public constant COOLDOWN_INTERVAL = 60;     // Seconds

    // Events
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event ExcludeFromAntiWhale(address indexed account, bool isExcluded);
    event EnableDisableAntiWhale(bool indexed new_status);
    event SetAntiWhaleMaxTransferRate(uint256 newRate, uint256 oldRate);
    event ExcludeFromCooldown(address indexed account, bool isExcluded);
    event EnableDisableCooldown(bool indexed new_status);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetMultisenderSmartContract(address indexed pair, bool indexed value);
    event SetNumberOfTransaction(uint256 new_value, uint256 old_value);
    event SetBlacklisted(address indexed account, bool old_status, bool new_status);
    event SetCanSnapshotWallet(address indexed account, bool indexed can_snapshot);
    event UpdatedPancakeRouter(address indexed newAddress, address indexed oldAddress, address indexed dexPair);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event ReflectionTokenChanged(address old_token, address new_token, address old_manager, address new_manager);
    event WithdrawnStuckTokens(address indexed token_address, uint256 amount, address recipient);
    event ProcessedReflectionDistribution(
        uint256 currentIndex,
        uint256 iterations,
        uint256 claims,
        bool indexed automatic,
        bool dismission_completed,
        uint256 gas,
        address indexed processor
    );
    event ProcessedReflectionDistributionOLD(
        uint256 currentIndex,
        uint256 iterations,
        uint256 claims,
        bool indexed automatic,
        bool dismission_completed,
        uint256 gas,
        address indexed processor
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 BNBreceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndSendAutomaticBuyback(
        uint256 tokensSwapped,
        uint256 amount
    );
    event SwapAndSendReflectionManager(
        uint256 tokensSwapped,
        uint256 amount
    );
    
 

    constructor(address TGE_destination) BEP20("Powermade", "PWD") {
        uint256 totalSupply = (14000000) * (10**18);    // 14M PWD

        // reflectionToken = BEP20(0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c);    // BTCB Mainnet
        // automaticBuyback_cumulatedToken = BEP20(0xe9e7cea3dedca5984780bafc599bd69add087d56);    // BUSD Mainnet
        reflectionToken = BEP20(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);    // ETH Testnet - 
        automaticBuyback_cumulatedToken = BEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);    // BUSD Testnet - https://bsc.pancake.kiemtienonline360.com/#/swap
        // Configure router and create liquidity pair
        // pancakeRouter = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);   // Router Mainnet
        pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);   // Router Testnet - https://bsc.pancake.kiemtienonline360.com/#/swap
        pancakePair = IPancakeFactory(pancakeRouter.factory()).createPair(address(this), pancakeRouter.WETH());

        // Create the Reflection Manager
        reflectionManager = new ReflectionManager();
        reflectionManager.initialize(address(reflectionToken));
        // reflectionManager.setDistributionCriteria(6 hours, 10**12, REFLECTION_ELIGIBILITY_THRESHOLD);   // 6 hours deadtime, 0.00001 BTCB threshold, 2000 PWD (immutable)
        reflectionManager.setDistributionCriteria(10 minutes, 10**12, REFLECTION_ELIGIBILITY_THRESHOLD);   // TESTNET
        // Create the AutomaticBuyback manager
        automaticBuyback = new AutomaticBuyback();
        automaticBuyback.initialize(address(pancakeRouter), address(automaticBuyback_cumulatedToken), address(this));
        // Create the Locker for the automated liquidity LP tokens
        LP_locker = new LPLocker();   // initial lock for 2 years
        // LP_locker.initialize(block.timestamp + 2 * 365 days);
        LP_locker.initialize(block.timestamp + 2 days);       // TESTNET

        // Add the AMM pair
        _setAutomatedMarketMakerPair(pancakePair, true);

        // Exclude from Reflection
        reflectionManager.setReflectionDisabledWallet(address(reflectionManager), true);
        reflectionManager.setReflectionDisabledWallet(address(this), true);
        reflectionManager.setReflectionDisabledWallet(owner(), true);
        reflectionManager.setReflectionDisabledWallet(TGE_destination, true);
        reflectionManager.setReflectionDisabledWallet(address(0), true);
        reflectionManager.setReflectionDisabledWallet(address(pancakeRouter), true);
        reflectionManager.setReflectionDisabledWallet(address(pancakePair), true);
        reflectionManager.setReflectionDisabledWallet(address(automaticBuyback), true);
        reflectionManager.setReflectionDisabledWallet(address(LP_locker), true);
        // Exclude from Tax system
        _excludeFromFees(owner(), true);
        _excludeFromFees(address(this), true);
        _excludeFromFees(TGE_destination, true);
        _excludeFromFees(address(automaticBuyback), true);
        _excludeFromFees(address(LP_locker), true);
        _excludeFromFees(address(reflectionManager), true);
        // Exclude from Anti-Whale
        _setExcludedFromAntiWhale(owner(), true);
        _setExcludedFromAntiWhale(address(this), true);
        _setExcludedFromAntiWhale(TGE_destination, true);
        _setExcludedFromAntiWhale(address(automaticBuyback), true);
        _setExcludedFromAntiWhale(address(LP_locker), true);
        _setExcludedFromAntiWhale(address(reflectionManager), true);
        // Exclude from Cooldown
        _setExcludedFromCooldown(owner(), true);
        _setExcludedFromCooldown(address(this), true);
        _setExcludedFromCooldown(TGE_destination, true);
        _setExcludedFromCooldown(address(automaticBuyback), true);
        _setExcludedFromCooldown(address(LP_locker), true);
        _setExcludedFromCooldown(address(reflectionManager), true);
        // Snapshot feature
        _setCanSnapshotWallet(owner(), true);
        _setCanSnapshotWallet(TGE_destination, true);
        
        // Create the tokens
        _mint(TGE_destination, totalSupply);

    }

    receive() external payable {}

    // Override needed for the BEP20Snapshot inheritance 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(BEP20, BEP20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }



    // ALL THE MAGIC IS HERE
    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Address Blacklisted');
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        // Things to be processed only if not inside internal swapping (reentrancy) and if not from a multi-sender smart contract
        if (!swapping && !multisenderSmartContract[from]) {

            // Apply Anti-whale
            _checkAntiWhale(from, to, amount);
            // Apply Cooldown
            _applyCooldown(from, to);

            // Process the automatic Buyback&Burn (if needed). The buyback has an internal swapping
            swapping = true;
            bool buyback_executed = automaticBuyback.trigger();
            if (buyback_executed) {
                // Burn all the tokens at the automaticBuyback address, reducing the supply
                _burn(address(automaticBuyback), balanceOf(address(automaticBuyback)));
            }
            swapping = false;

        }

        // Decide if we have to process the cumulated tax, swapping to the needed tokens (BTCB and BUSD)
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 executeSwapFeature = tx_counter.mod(transactionsBeforeExecution);
        bool canSwap = executeSwapFeature < 3 && contractTokenBalance > 0;
        if (!swapping) { tx_counter++; }
        if ( canSwap &&
            !swapping &&
            from != owner() &&
            to != owner() &&
            !multisenderSmartContract[from]
        ) {
            swapping = true;
            if (amountBuybackTax > 0 && executeSwapFeature == 0) {
                _swapAndSendAutomaticBuyback(amountBuybackTax);
            }
            if (amountLiquidityTax > 0 && executeSwapFeature == 1) {
                _swapAndLiquify(amountLiquidityTax);
            }
            if (amountReflectionTax > 0 && executeSwapFeature == 2) {
                _swapAndSendReflectionManager(amountReflectionTax);
            }
            swapping = false;
        }

        // If not swapping, take the tax. This will happen on all transactions, buy and sell
        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the tax
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        // Take and cumulate the fees
        if(takeFee) {
            uint256 reflection_amount = amount.mul(REFLECTION_TAX).div(100);
            uint256 buyback_amount = amount.mul(BUYBACK_AND_BURN_TAX).div(100);
            uint256 liquidity_amount = amount.mul(AUTOMATED_LIQUIDITY_TAX).div(100);
            uint256 total_tax_amount = reflection_amount.add(buyback_amount).add(liquidity_amount);
            // Apply tax
            amount = amount.sub(total_tax_amount);
            // Cumulate the tax (PWD) inside the contract
            super._transfer(from, address(this), total_tax_amount);
            // Update the storage variables
            amountReflectionTax = amountReflectionTax.add(reflection_amount);
            amountBuybackTax = amountBuybackTax.add(buyback_amount);
            amountLiquidityTax = amountLiquidityTax.add(liquidity_amount);
        }

        // Do the transfer
        super._transfer(from, to, amount);

        // Update and process the ReflectionManager (if not swapping, see the internal function)
        _updateAndProcessReflectionManagers(from, to);

    }



    // Swap the given amount of PWD to the automaticBuyback_cumulatedToken (BUSD) and send it to the AutomaticBuyback SC address
    function _swapAndSendAutomaticBuyback(uint256 amount) private {
        // Swap amount and send it to the Automatic buyback SC
        uint256 received_amount = _swapPWDtoTokenAndSendToRecipient(automaticBuyback_cumulatedToken, amount, address(automaticBuyback));
        // Update the local variable
        amountBuybackTax = amountBuybackTax.sub(amount);
        emit SwapAndSendAutomaticBuyback(amount, received_amount);
    }


    // Swap the given amount of PWD to the reflectionToken (BTCB) and send it to the ReflectionManager, updating the dividend-per-shares
    function _swapAndSendReflectionManager(uint256 amount) private {
        // Swap amount and send it to the reflection manager directly 
        uint256 received_amount = _swapPWDtoTokenAndSendToRecipient(reflectionToken, amount, address(reflectionManager));
        // Update the reflection manager
        reflectionManager.update_deposit(received_amount);
        // Update the local variable
        amountReflectionTax = amountReflectionTax.sub(amount);
        emit SwapAndSendReflectionManager(amount, received_amount);
    }


    // Swap half of the PWD amount to BNB and use the two to add liquidity on the DEX pair
    function _swapAndLiquify(uint256 amount) private {
       // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);
        uint256 initialBalance = address(this).balance;     // To exclude BNB already present in the contract
        uint256 initialBalancePWD = balanceOf(address(this));     // To count remaining in PWD
        // swap the first half to BNB
        _swapPWDtoBNB(half);
        // Get the obtained BNBs
        uint256 newBalance = address(this).balance.sub(initialBalance);
        // add liquidity to the pair
        _addLiquidityPWDandBNBpair(otherHalf, newBalance);
        // Real amount of PWD used to provide liquidity, ideally equal to amount (half+otherHalf)
        uint256 realPWDamountUsed = initialBalancePWD.sub(balanceOf(address(this)));
        amountLiquidityTax = amountLiquidityTax.sub(realPWDamountUsed);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }     


    // Swap PWD to the specified BEP20 Token, for tokenAmount quantity of PWD, and send the received tokens to the recipient address
    function _swapPWDtoTokenAndSendToRecipient(BEP20 token, uint256 tokenAmount, address recipient) private returns (uint256 amount_received) {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        path[2] = address(token);
        _approve(address(this), address(pancakeRouter), tokenAmount);
        uint256 initialBalance = token.balanceOf(recipient);
        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,      // Accept any amount of converted Token
            path,
            recipient,      // Send to the given recipient address
            block.timestamp
        );
        return token.balanceOf(recipient).sub(initialBalance);
    }    


    // Swap PWD to BNB (WBNB) sending the BNB to the PWD token address (that has the receive() fallback)
    function _swapPWDtoBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();
        _approve(address(this), address(pancakeRouter), tokenAmount);
        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,      // accept any amount of BNB
            path,
            address(this),      // Receive the BNB in the contract (fallback function)
            block.timestamp
        );
    }


    // Add the liquidity to the PWD-WBNB pair on the DEX, sending the LP tokens directly to the LPLocker Vault
    function _addLiquidityPWDandBNBpair(uint256 tokenAmount, uint256 BNBamount) private {
        _approve(address(this), address(pancakeRouter), tokenAmount);
        // add the liquidity
        pancakeRouter.addLiquidityETH{value: BNBamount}(
            address(this),      // PWD
            tokenAmount,
            0,      // slippage is unavoidable
            0,      // slippage is unavoidable
            address(LP_locker),
            block.timestamp
        );
    }


    // Internal private function to update the shares in the ReflectionManager ad process the distribution with the configured gas (if not in swapping)
    function _updateAndProcessReflectionManagers(address from, address to) private {

        // Update the shares 
        reflectionManager.setShare(from, balanceOf(from));
        reflectionManager.setShare(to, balanceOf(to));

        if (!swapping && !multisenderSmartContract[from]) { return; }   // Continue only if not swapping and not from a multi-sender contract

        // Process the distribution (managing also the condition of reflectionToken change)
        if (address(reflectionManagerOld) != address(0)) {
            bool is_old_dismission_completed;
            ( , is_old_dismission_completed) = reflectionManagerOld.isDismission();
            if (is_old_dismission_completed) {
                delete reflectionManagerOld;        // Clear the variable (it will return address(0))
            } else {
                uint256 gas = gasForProcessing.div(2);      // Half the gas for each processing
                // Process old
                try reflectionManagerOld.process(gas) returns (uint256 currentIndex, uint256 iterations, uint256 claims, bool dismission_completed) {
                    emit ProcessedReflectionDistributionOLD(currentIndex, iterations, claims, true, dismission_completed, gas, tx.origin);
                } catch { }
                // Process Current
                try reflectionManager.process(gas) returns (uint256 currentIndex, uint256 iterations, uint256 claims, bool dismission_completed) {
                    emit ProcessedReflectionDistribution(currentIndex, iterations, claims, true, dismission_completed, gas, tx.origin);
                } catch { }
            }
        } else {
            // Process only current
            uint256 gas = gasForProcessing;
            try reflectionManager.process(gas) returns (uint256 currentIndex, uint256 iterations, uint256 claims, bool dismission_completed) {
                emit ProcessedReflectionDistribution(currentIndex, iterations, claims, true, dismission_completed, gas, tx.origin);
            } catch { }            
        }

    }


    // Anti-Whale check: applied to ALL transaction except BUY from AMM pairs
    function _checkAntiWhale(address sender, address recipient, uint256 amount) view private {
        uint256 maxTransferAmount = totalSupply().mul(maxTransferAmountRate).div(1000000);
        if (enableAntiwhale && !automatedMarketMakerPairs[sender]) {
            if (!_isExcludedFromAntiWhale[sender] && !_isExcludedFromAntiWhale[recipient]) {
                require(amount <= maxTransferAmount, "AntiWhale: Transfer amount exceeds the maxTransferAmount");
            }
        }
    }


    // Cooldown feature applied only to buy and sell operations on the defined automatedMarketMakerPairs
    // Applied only if feature enabled and addresses not exempt
    function _applyCooldown(address sender, address recipient) private {
        if (cooldownEnabled && !_isTimelockExempt[sender] && !_isTimelockExempt[recipient] 
        ) {
            if (automatedMarketMakerPairs[sender]) {
                // Buy event - the sender is the pair
                require(cooldownTimer[recipient] < block.timestamp,"Please wait for 1 min between two buys/sells");
                cooldownTimer[recipient] = block.timestamp + COOLDOWN_INTERVAL;
            } else if (automatedMarketMakerPairs[recipient]) {
                // Sell event - the recipient is the pair
                require(cooldownTimer[sender] < block.timestamp,"Please wait for 1 min between two buys/sells");
                cooldownTimer[sender] = block.timestamp + COOLDOWN_INTERVAL;
            }
        }
    }

    // Trigger the execution of the Tax conversion manually
    function swapManual() public onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0 , "token balance zero");
        swapping = true;
        if (amountBuybackTax > 0) {
            _swapAndSendAutomaticBuyback(amountBuybackTax);
        }
        if (amountLiquidityTax > 0) {
            _swapAndLiquify(amountLiquidityTax);
        }
        if (amountReflectionTax > 0) {
            _swapAndSendReflectionManager(amountReflectionTax);
        }
        swapping = false;
    }


    // Set a liquidity pair
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        if(value) {
            reflectionManager.setReflectionDisabledWallet(pair, true);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    // Set a Multi-sender smart contract (i.e. used to send airdrops). In this case the gas-intensive features won't be triggered during the transaction
    function setMultisenderSmartContract(address multisender_sc, bool value) external onlyOwner {
        _requireNotInternalAddresses(multisender_sc, true);
        require(!automatedMarketMakerPairs[multisender_sc], "Configuration: multisender_sc cannot be an AMM pair");
        multisenderSmartContract[multisender_sc] = value;
        emit SetMultisenderSmartContract(multisender_sc, value);
    }

    // Exclude (or re-include) a single wallet (or smart contract) from the tax system 
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _requireNotInternalAddresses(account, false);
        _excludeFromFees(account, excluded);
    }

    // _excludeFromFees internal function
    function _excludeFromFees(address account, bool excluded) internal {
        if (_isExcludedFromFees[account] != excluded) {
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    // Exclude (or re-include) multiple wallets (or smart contracts) from the tax system 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        require(accounts.length <= 10, "Configuration: max 10 accounts per time");
        for(uint256 i = 0; i < accounts.length; i++) {
            _requireNotInternalAddresses(accounts[i], false);
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    // Check if an address is excluded from the tax system
    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    // Exclude (or re-include) a single wallet (or smart contract) from the anti-whale system 
    function setExcludedFromAntiWhale(address account, bool excluded) public onlyOwner {
        _requireNotInternalAddresses(account, false);
        _setExcludedFromAntiWhale(account, excluded);
    }

    // _setExcludedFromAntiWhale internal function
    function _setExcludedFromAntiWhale(address account, bool excluded) internal {
        if (_isExcludedFromAntiWhale[account] != excluded) {
            _isExcludedFromAntiWhale[account] = excluded;
            emit ExcludeFromAntiWhale(account, excluded);
        }  
    }

    // Check if an address is excluded from the anti-whale system
    function isExcludedFromAntiWhale(address account) public view returns(bool) {
        return _isExcludedFromAntiWhale[account];
    }

    // Enable or disable Anti-Whale system
    function setEnableAntiwhale(bool _val) public onlyOwner {
        enableAntiwhale = _val;
        emit EnableDisableAntiWhale(_val);
    }

    // Exclude (or re-include) a single wallet (or smart contract) from the cooldown system
    function setExcludedFromCooldown(address account, bool excluded) public onlyOwner {
        _requireNotInternalAddresses(account, false);
        _setExcludedFromCooldown(account, excluded);
    }

    // _setExcludedFromCooldown internal function
    function _setExcludedFromCooldown(address account, bool excluded) internal {
        if (_isTimelockExempt[account] != excluded) {
            _isTimelockExempt[account] = excluded;
            emit ExcludeFromCooldown(account, excluded);
        }  
    }

    // Enable or Disable a wallet that can call the makeSnapshot() function
    function setCanSnapshotWallet(address account, bool can_snapshot) public onlyOwner {
        _requireNotInternalAddresses(account, true);
        _setCanSnapshotWallet(account, can_snapshot);
    }

    // _setCanSnapshotWallet internal function
    function _setCanSnapshotWallet(address account, bool can_snapshot) internal {
        _canSnapshot[account] = can_snapshot;
        emit SetCanSnapshotWallet(account, can_snapshot);
    }

    // Check if an address is excluded from the Cooldown system
    function isExcludedFromCooldown(address account) public view returns(bool) {
        return _isTimelockExempt[account];
    }

    // Enable or disable Cooldown system
    function setEnableCooldown(bool _val) public onlyOwner {
        cooldownEnabled = _val;
        emit EnableDisableCooldown(_val);
    }

    // Set the transaction amount that is considered a "Whale" in terms of a percentage of the supply (minimum 0.1%)
    function setMaxTransferAmountRate(uint256 _val) external onlyOwner {
        require(_val >= 1000, "AntiWhale: minimum value is 1000 (0.1% of the Supply)");
        emit SetAntiWhaleMaxTransferRate(_val, maxTransferAmountRate);
        maxTransferAmountRate = _val;
    }

    // Add or remove a new AMM pair (PancakeSwap and/or different DEXs)
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        _requireNotInternalAddresses(pair, true);
        require(!multisenderSmartContract[pair], "Configuration: pair cannot be the a multisender SC");
        _setAutomatedMarketMakerPair(pair, value);
    }

    // Set the number of transactions between each feature execution sequence
    function setNumberOfTransactionsBeforeExecution(uint256 _numberOfTransactions) external onlyOwner {
        require(_numberOfTransactions >= 3 && _numberOfTransactions < 100, "Configuration: valid values are >=3 and < 100");
        emit SetNumberOfTransaction(_numberOfTransactions, transactionsBeforeExecution);
        transactionsBeforeExecution = _numberOfTransactions;
    }

    // Add an account to the blacklist in case of hacks or regulatory compliance
    function blacklistAddress(address account, bool value) external onlyOwner {
        _requireNotInternalAddresses(account, true);
        emit SetBlacklisted(account, _isBlacklisted[account], value);
        _isBlacklisted[account] = value;
    }

    // Check if an account is blacklisted
    function isBlacklistedAddress(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    // Change the gas used for the Reflection distribution
    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 700000, "Configuration: GasForProcessing must be between 200,000 and 700,000");
        require(newValue != gasForProcessing, "Configuration: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    // Change the thresholds for the automatic reflection distribution
    function setReflectionDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        reflectionManager.setDistributionCriteria(_minPeriod, _minDistribution, REFLECTION_ELIGIBILITY_THRESHOLD);
    }

    // Enable or disable a reflection-receiving smart contract (other contracts excluded by default)
    function setReflectionEnabledContract(address _contractAddress, bool _enableDisable) external onlyOwner {
        _requireNotInternalAddresses(_contractAddress, true);
        reflectionManager.setReflectionEnabledContract(_contractAddress, _enableDisable);
    }

    // Disable or re-enable a reflection-receiving wallet
    function setReflectionDisabledWallet(address _walletAddress, bool _disableEnable) external onlyOwner {
        _requireNotInternalAddresses(_walletAddress, true);
        reflectionManager.setReflectionDisabledWallet(_walletAddress, _disableEnable);
    }

    function _requireNotInternalAddresses(address _walletAddress, bool includePancake) internal view {
        require(_walletAddress != owner() && 
                _walletAddress != address(0) && 
                _walletAddress != address(this) && 
                _walletAddress != address(LP_locker) &&
                _walletAddress != address(reflectionManager), 
                "Configuration: cannot modify the given address");
        if (includePancake) {
            require(_walletAddress != address(pancakeRouter) && 
                    _walletAddress != address(pancakePair), 
                    "Configuration: cannot modify the given address");
        }
    }

    // Enable or disable the Reflection automatic claim for an address/shareholder
    function setReflectionAutoDistributionExcludeFlag(address _shareholder, bool _exclude) external  onlyOwner {
        reflectionManager.setAutoDistributionExcludeFlag(_shareholder, _exclude);
    }

    // Return Reflection Info of an account (shareholder)
    function getReflectionAccountInfo(address shareholder) public view returns (
            uint256 shareholder_id,     // it is index+1, zero if shareholder not in list
            uint256 currentShares,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalRealisedDividends,
            uint256 totalExcludedDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            bool shouldAutoDistribute,
            bool excludedAutoDistribution,
            bool enabled ) {
        return reflectionManager.getAccountInfo(shareholder);
    }

    // Get the address of a Reflection shareholder given the index (from 0)
    function getReflectionShareholderAtIndex(uint256 index) public view returns (address) {
        return reflectionManager.getShareholderAtIndex(index);
    }

    // Returns global info of the reflection manager
    function getReflectionManagerInfo() public view returns (
            uint256 n_shareholders,
            uint256 current_index,
            uint256 manager_balance,
            uint256 total_shares,
            uint256 total_dividends,
            uint256 total_distributed,
            uint256 dividends_per_share,
            uint256 eligibility_threshold_shares,
            uint256 min_period,
            uint256 min_distribution,
            uint8 dismission ) {
        return reflectionManager.getReflectionManagerInfo();
    }

    // Manually process the dividend distribution (everyone can call this function). Suggested gas between 200,000 and 700,000
    function processReflectionDistribution(uint256 gas) external {
        (uint256 currentIndex, uint256 iterations, uint256 claims, bool dismission_completed) = reflectionManager.process(gas);
        emit ProcessedReflectionDistribution(currentIndex, iterations, claims, false, dismission_completed, gas, tx.origin);
    }

    // Manually process the dividend distribution of the OLD (marked for dismission) Reflection Manager (everyone can call this function). Suggested gas between 200,000 and 700,000
    function processReflectionDistributionOLD(uint256 gas) external {
        require(address(reflectionManagerOld) != address(0), "Old ReflectionManager does not exists or is completely dismissed");
        (uint256 currentIndex, uint256 iterations, uint256 claims, bool dismission_completed) = reflectionManagerOld.process(gas);
        if (dismission_completed) {
            // Clear the old Reflection Manager (set the address to NULL address)
            delete reflectionManagerOld;
        }
        emit ProcessedReflectionDistributionOLD(currentIndex, iterations, claims, false, dismission_completed, gas, tx.origin);
    }

    function changeReflectionManager(address newUninitializedReflectionManager, address newReflectionToken, uint256 _minDistribution) external onlyOwner {
        require(address(reflectionManagerOld) == address(0), "Configuration: change reflectionManager possible only with the old reflectionManager not existent dismissed");
        // Initialize the passed uninitialized reflection manager, using the provided token address and the given min distribution value
        ReflectionManager new_reflection_manager = ReflectionManager(newUninitializedReflectionManager);
        new_reflection_manager.initialize(newReflectionToken);
        // Configure the new reflection manager
        new_reflection_manager.setDistributionCriteria(6 hours, _minDistribution, REFLECTION_ELIGIBILITY_THRESHOLD);
        // Exclude from Reflection. Remember to add manually the other addresses if any
        new_reflection_manager.setReflectionDisabledWallet(address(reflectionManager), true);
        new_reflection_manager.setReflectionDisabledWallet(address(reflectionManagerOld), true);
        new_reflection_manager.setReflectionDisabledWallet(address(this), true);
        new_reflection_manager.setReflectionDisabledWallet(owner(), true);
        new_reflection_manager.setReflectionDisabledWallet(address(0), true);
        new_reflection_manager.setReflectionDisabledWallet(address(pancakeRouter), true);
        new_reflection_manager.setReflectionDisabledWallet(address(pancakePair), true);
        new_reflection_manager.setReflectionDisabledWallet(address(automaticBuyback), true);
        new_reflection_manager.setReflectionDisabledWallet(address(LP_locker), true);
        // Other excludes
        _excludeFromFees(address(new_reflection_manager), true);
        _setExcludedFromAntiWhale(address(new_reflection_manager), true);
        _setExcludedFromCooldown(address(new_reflection_manager), true);
        // Change the reflection token 
        BEP20 old_reflectionToken = reflectionToken;
        reflectionToken = BEP20(newReflectionToken);
        // Set the current ReflectionManager as OLD and assign the new ReflectionManager
        reflectionManagerOld = reflectionManager;   
        reflectionManager = new_reflection_manager;
        // Dismiss the old reflection manager
        reflectionManagerOld.dismissReflectionManager();
        emit ReflectionTokenChanged(address(old_reflectionToken), address(reflectionToken), address(reflectionManagerOld), address(reflectionManager));
    }

    // Manually claim the reflection rewards of the sender
    function claimReflection() external {
        reflectionManager.claimDividend(_msgSender());
    }

    // Manually claim the reflection rewards of a shareholder
    function claimReflectionShareholder(address shareholder) external {
        reflectionManager.claimDividend(shareholder);
    }

    // Withdraw LP tokens from the Lp vault (if unlocked)
    function LPLockerWithdrawLP(address _LPaddress, uint256 _amount, address _to) external onlyOwner {
        LP_locker.withdrawLP(_LPaddress, _amount, _to);
    }

    // Update the Lock timestamp of the LPLocker
    function LPLockerUpdateLock(uint256 _newUnlockTimestamp) external onlyOwner {
        LP_locker.updateLock(_newUnlockTimestamp);
    }

    // Return the status of the LPLock vault, its address and the balance of the provided _LPaddress (if different from NULL address)
    function getLPLockerInfoLP(address _LPaddress) public view returns (address locker_address, uint256 LPbalance, uint256 unlock_timestamp, bool unlocked) {
        return LP_locker.getInfoLP(_LPaddress);
    }

    // External function to change the automatic buyback period between 30, 60 or 90 days
    function changeBuybackPeriod(uint8 newPeriod) external onlyOwner {
        automaticBuyback.changeBuybackPeriod(newPeriod);
    }

    // Change the cumulated token used for the automatic buyback
    function changeBuybackCumulatedToken(address newCumulatedTokenAddress) external onlyOwner {
        automaticBuyback.changeCumulatedToken(newCumulatedTokenAddress);
        automaticBuyback_cumulatedToken = BEP20(newCumulatedTokenAddress);
    }

    // Return the current status of the AutomaticBuyback and the countdown to the next automatic buyback event
    function getAutomaticBuybackStatus() public view returns (
            address automatic_buyback_contract_address,
            uint256 next_buyback_timestamp,
            uint256 next_buyback_countdown,
            uint8 current_buyback_period,
            uint8 new_buyback_period,
            address current_cumulated_token,
            uint256 current_cumulated_balance,
            uint256 current_buyback_token_balance,
            uint256 total_buyed_back ) {
        return automaticBuyback.getAutomaticBuybackStatus();
    }

    // Switch/Change PancakeSwap Router
    function updatePancakeRouter(address newAddress) external onlyOwner {
        require(newAddress != address(pancakeRouter), "The router already has that address");
        IPancakeRouter02 _newRouter = IPancakeRouter02(newAddress);
        address get_pair = IPancakeFactory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        //checks if pair already exists
        if (get_pair == address(0)) {
            pancakePair = IPancakeFactory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            pancakePair = get_pair;
        }
        _setAutomatedMarketMakerPair(pancakePair, true);
        emit UpdatedPancakeRouter(newAddress, address(pancakeRouter), address(pancakePair));
        pancakeRouter = _newRouter;
        // Update address for the automatic buyback manager
        automaticBuyback.updateRouterAddress(address(pancakeRouter));
    }

    // Withdraw stuck tokens inside the contract. Stuck tokens can be BNB or another token
    // It will be impossible to withdraw the PWD cumulated inside the token itself
    // The refection (BTCB) and the Buyback (BUSD) are managed by separated contract so the only allowed token inside this contract is PWD
    function withdrawStuckTokens(address token_address, uint256 amount, address recipient) external onlyOwner {
        if (token_address == address(0)) {
            // Withdraw stuck BNB
            uint256 available_amount = address(this).balance;
            amount = amount > available_amount ? available_amount : amount;     //coerce
            payable(recipient).transfer(amount);
        } else {
            // Withdraw Stuck tokens
            require(token_address != address(this), "Cannot withdraw the PWD!");
            BEP20 token_bep20 = BEP20(token_address);
            uint256 available_amount = token_bep20.balanceOf(address(this));
            amount = amount > available_amount ? available_amount : amount;     //coerce
            token_bep20.transfer(recipient, amount);
        }
        emit WithdrawnStuckTokens(token_address, amount, recipient);
    }

    // Function used to create a Snapshot by allowed people 
    function makeSnapshot() external {
        require(_canSnapshot[_msgSender()], "Not authorized");
        _snapshot();
    }


}