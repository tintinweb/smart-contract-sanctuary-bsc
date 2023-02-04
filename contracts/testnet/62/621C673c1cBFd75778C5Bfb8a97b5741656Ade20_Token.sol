// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./ERC20.sol";
import "./Pausable.sol";
import "./IPancakeRouter02.sol";
import "./IPancakeV2Pair.sol";
import "./IPancakeV2Factory.sol";

/**
 * @title Token.
 */
contract Token is ERC20, Pausable {
    // Defining tax variables
    uint256 public burnFeesBuy = 100; // percentage to burn when buying
    uint256 public rewardsFeesBuy = 100; // percentage to put aside for stakig rewards when buying
    uint256 public BBDDWalletFeesBuy = 0; // percentage to send to BBDD wallet when buying
    uint256 public tresoWalletFeesBuy = 100; // percentage to send to reserve wallet when buying

    uint256 public burnFeesSell = 100; // percentage to burn when selling
    uint256 public rewardsFeesSell = 200; // percentage to put aside for rewards when selling
    uint256 public BBDDWalletFeesSell = 100; // percentage to send to BBDD wallet when selling
    uint256 public tresoWalletFeesSell = 100; // percentage to send to tresorie wallet when selling
    uint256 public tokensToSwapPercentage = 5000; // percentage to swap TNEC stored on smart contract

    bool public feesEnabled = true; // enable fees for all swap operations

    uint256 public MAX_TAX = 3000; // maximum allowed tax per transaction
    uint256 public constant DENOMINATOR = 10_000;

    mapping(address => bool) public whitelist; // list of addresses excluded from paying fees
    mapping(address => bool) public isMember; // list of actif members
    mapping(address => bool) private _owners; // list of owners
    mapping(address => bool) public blacklist; // list of addresses excluded from interacting with the smart contract

    address public BBDDWallet; // BBDD wallet
    address public tresoWallet; // Treso wallet
    address public rewardsWallet; // rewards wallet

    uint256 public toBBDD; // BBDD fees to be swapped to USDC
    uint256 public toTreso; // Treso fees to be swapped to USDC
    uint256 public toRewards; // Rewards fees to be swapped to USDC

    address public mainLP; // this LP pair is considered to be the main source of liquidity
    mapping(address => bool) public LPs; // sending to these addresses is considered a token sale

    address public constant USDC = 0x64544969ed7EBf5f083679233325356EbE738930; // USDC smart contract address

    IPancakeRouter02 public router; // router where the token is listed and has most of its USDC liquidity

    /// @notice onlyAuthorized is a modifier to verify if the sender is a member or whitelisted
    modifier onlyAuthorized() {
        require(isMember[msg.sender] || whitelist[msg.sender], "TNEC: caller is not whitelisted or a member");
        _;
    }

    ///@notice Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(_owners[msg.sender], "TNEC: caller is not owner");
        _;
    }

    /// @notice notBlacklisted is a modifier to verify if the sender is blacklisted or not
    modifier notBlacklisted() {
        require(!blacklist[msg.sender], "TNEC: caller is blacklisted ");
        _;
    }

    ///@notice constructor, to initialize the smart contract
    ///@param _router, router address
    ///@param _BBDDWallet, BBDD wallet
    ///@param _tresoWallet, reserve wallet
    ///@param _totalSupply, total supply token
    constructor(
        address _router,
        address _BBDDWallet,
        address _tresoWallet,
        address _rewardsWallet,
        uint256 _totalSupply
    ) ERC20("Test token", "TEST") {
        _setOwner(address(0), msg.sender);
        setRouter(_router);
        setBBDDWallet(_BBDDWallet);
        settresoWallet(_tresoWallet);
        setRewardWallet(_rewardsWallet);
        _mint(msg.sender, _totalSupply);
        addToWhitelist(msg.sender);
        addToWhitelist(address(this));
        addToWhitelist(BBDDWallet);
        addToWhitelist(tresoWallet);
        addToWhitelist(rewardsWallet);
    }

    ///@notice receive, required to recieve BNB
    receive() external payable {}

    /// @notice withdrawBNB, required to withdraw BNB from this smart contract, only Owner can call this function
    /// @param amount number of BNB to be transfered
    function withdrawBNB(uint256 amount) public onlyOwner {
        if (amount == 0) payable(msg.sender).transfer(address(this).balance);
        else payable(msg.sender).transfer(amount);
    }

    /// @notice transferBNBToAddress, required to transfer BNB from this smart contract to recipient, only Owner can call this function
    /// @param recipient of BNB
    /// @param amount number of tokens to be transfered
    function transferBNBToAddress(address payable recipient, uint256 amount)
        public
        onlyOwner
    {
        recipient.transfer(amount);
    }

    /// @notice withdrawForeignToken, required to withdraw foreign tokens from this smart contract, only Owner can call this function
    /// @param token address of the token to withdraw
    function withdrawForeignToken(address token) public onlyOwner {
        require(!LPs[token], "Cannot withdraw LP tokens");
        if (token == address(this)) {
            uint256 toSend;
            toSend = ERC20(token).balanceOf(address(this));
            require(
                toSend > toBBDD + toTreso + toRewards,
                "Cannot withdraw native token, not enough to swap !"
            );
            toSend = toSend - (toBBDD + toTreso + toRewards);
            transfer(msg.sender, toSend);
        }
        ERC20(address(token)).transfer(
            msg.sender,
            ERC20(token).balanceOf(address(this))
        );
    }

    /**
     * @notice Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _owners[msg.sender] = false;
        whitelist[msg.sender] = false;
        _setOwner(msg.sender, address(0));
    }

    /**
     * @notice Returns the address of the current owner.
     */
    function owner(address _owner) public view returns (bool) {
        return _owners[_owner];
    }

    ///@notice Transfers ownership of the contract to a new account (`newOwner`), can only be called by the current owner.
    ///@param _newOwner, addresss of the new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        whitelist[msg.sender] = false;
        _setOwner(msg.sender, _newOwner);
        whitelist[_newOwner] = true;
    }

    ///@notice addNewOwner, add a new owner
    ///@param _newOwner, addresss of the new owner
    function addNewOwner(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(address(0), _newOwner);
        whitelist[_newOwner] = true;
    }

    ///@notice _setOwner, the address of the current owner
    ///@param _newOwner, addresss of the new owner
    ///@param _oldOwner, addresss of the old owner
    function _setOwner(address _oldOwner, address _newOwner) internal {
        _owners[_oldOwner] = false;
        _owners[_newOwner] = true;
    }

    /// @notice lockLiquidity, required to lock liquidity, only Owner can call this function
    /// @param amountADesired number of tokens A to lock
    /// @param amountBDesired number of tokens B to lock
    /// LP Cake tokens with be blocked to this address
    function lockLiquidity(uint256 amountADesired, uint256 amountBDesired)
        external
        onlyOwner
    {
        router.addLiquidity(
            address(this),
            USDC,
            amountADesired,
            amountBDesired,
            0,
            0,
            address(this),
            1e18 // absurdly high value
        );
    }

    /// @notice zeroAllTaxes required to remove all fees, only Owner can call this function
    function zeroAllTaxes() external onlyOwner {
        burnFeesBuy = 0;
        rewardsFeesBuy = 0;
        BBDDWalletFeesBuy = 0;
        tresoWalletFeesBuy = 0;

        burnFeesSell = 0;
        rewardsFeesSell = 0;
        BBDDWalletFeesSell = 0;
        tresoWalletFeesSell = 0;

        feesEnabled = false;
    }

    /// @notice getAllTaxes, to get all taxes
    function getAllTaxes() public
    view
    returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (burnFeesBuy,
        rewardsFeesBuy,
        BBDDWalletFeesBuy,
        tresoWalletFeesBuy,
        burnFeesSell,
        rewardsFeesSell,
        BBDDWalletFeesSell,
        tresoWalletFeesSell);
    }

    /// @notice setAllTaxes required to set all fees, only Owner can call this function
    /// @param  _burnFeesBuy, burn fees when buying
    /// @param  _burnFeesSell, burn fees when selling
    /// @param  _rewardsFeesBuy, staking fees when buying
    /// @param  _rewardsFeesSell, staking fees when selling
    /// @param  _BBDDWalletFeesBuy, BBDD fees when buying
    /// @param  _BBDDWalletFeesSell, BBDD fees when selling
    /// @param  _tresoWalletFeesBuy, reserve fees when buying
    /// @param  _tresoWalletFeesSell, reserve fees when selling
    function setAllTaxes(
        uint256 _burnFeesBuy,
        uint256 _burnFeesSell,
        uint256 _rewardsFeesBuy,
        uint256 _rewardsFeesSell,
        uint256 _BBDDWalletFeesBuy,
        uint256 _BBDDWalletFeesSell,
        uint256 _tresoWalletFeesBuy,
        uint256 _tresoWalletFeesSell
    ) external onlyOwner {
        burnFeesBuy = _burnFeesBuy;
        rewardsFeesBuy = _rewardsFeesBuy;
        BBDDWalletFeesBuy = _BBDDWalletFeesBuy;
        tresoWalletFeesBuy = _tresoWalletFeesBuy;
        require(
            burnFeesBuy +
                rewardsFeesBuy +
                BBDDWalletFeesBuy +
                tresoWalletFeesBuy <=
                MAX_TAX,
            "TNEC : Buy fees cannot exceed the MAX"
        );

        burnFeesSell = _burnFeesSell;
        rewardsFeesSell = _rewardsFeesSell;
        BBDDWalletFeesSell = _BBDDWalletFeesSell;
        tresoWalletFeesSell = _tresoWalletFeesSell;
        require(
            burnFeesSell +
                rewardsFeesSell +
                BBDDWalletFeesSell +
                tresoWalletFeesSell <=
                MAX_TAX,
            "TNEC : Buy fees cannot exceed the MAX"
        );

        feesEnabled = true;
    }

    /// @notice setRewardWallet, update the reward wallet, only Owner can call this function
    /// @param  _newRewardWallet, new reward address
    function setRewardWallet(address _newRewardWallet) public onlyOwner {
        require(_newRewardWallet != address(0), "TNEC : cannot be the zero address");
        rewardsWallet = _newRewardWallet;
    }

    /// @notice setBBDDWallet, update the BBDD wallet, only Owner can call this function
    /// @param  _newBBDDWallet, new BBDD address
    function setBBDDWallet(address _newBBDDWallet) public onlyOwner {
        require(_newBBDDWallet != address(0), "TNEC : cannot be the zero address");
        BBDDWallet = _newBBDDWallet;
    }

    /// @notice settresoWallet, update the reserve wallet, only Owner can call this function
    /// @param  _newtresoWallet, new reserve address
    function settresoWallet(address _newtresoWallet) public onlyOwner {
        require(_newtresoWallet != address(0), "TNEC : cannot be the zero address");
        tresoWallet = _newtresoWallet;
    }

    /// @notice addToWhitelist, add an account to the whitelist to pay no fees, only Owner can call this function
    /// @param  account, account to whitelist
    function addToWhitelist(address account) public onlyOwner {
        require(!whitelist[account], "TNEC : account is already whitelisted");
        whitelist[account] = true;
    }

    /// @notice removeFromWhitelist, remove an account to the whitelist to pay fees, only Owner can call this function
    /// @param  account, account to blacklist
    function removeFromWhitelist(address account) public onlyOwner {
        require(whitelist[account], "TNEC : account is not whitelisted");
        whitelist[account] = false;
    }

    /// @notice addToBlacklist, add an account to the blacklist, only Owner can call this function
    /// @param  account, account to blacklist
    function addToBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "TNEC : account is already blacklisted");
        blacklist[account] = true;
    }

    /// @notice removeFromBlacklist, remove an account to the blacklist to pay fees, only Owner can call this function
    /// @param  account, account to blacklist
    function removeFromBlacklist(address account) public onlyOwner {
        require(blacklist[account], "TNEC : account is not blacklisted");
        blacklist[account] = false;
    }

    /// @notice addToMembers, add an account to members list, only Owner can call this function
    /// @param  account, account to members list
    function addToMembers(address account) public onlyOwner {
        require(!isMember[account], "TNEC: account is already a member");
        isMember[account] = true;
    }

    /// @notice removeFromMembers, remove an account to members list, only Owner can call this function
    /// @param  account, account to members list
    function removeFromMembers(address account) public onlyOwner {
        require(isMember[account], "TNEC: account is not a member ");
        isMember[account] = false;
    }

    /// @notice addMultipleToBlacklist, add multiple accounts to blacklist, only Owner can call this function
    /// @param  accounts, accounts to add to blacklist 
    function addMultipleToBlacklist(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(
                !blacklist[accounts[i]],
                "TNEC: account is already blacklisted !"
            );
            blacklist[accounts[i]] = true;
        }
    }

    /// @notice removeMultipleFromBlacklist, remove multiple accounts to Blacklist, only Owner can call this function
    /// @param  accounts, accounts to remove from members list
    function removeMultipleFromBlacklist(address[] memory accounts)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(blacklist[accounts[i]], "TNEC: account is not blacklisted !");
            blacklist[accounts[i]] = false;
        }
    }

    /// @notice addMultipleToMembers, add multiple accounts to members list, only Owner can call this function
    /// @param  accounts, accounts to add to members list
    function addMultipleToMembers(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(
                !isMember[accounts[i]],
                "TNEC: account is already a member"
            );
            isMember[accounts[i]] = true;
        }
    }

    /// @notice removeMultipleFromMembers, remove multiple accounts to members list, only Owner can call this function
    /// @param  accounts, accounts to remove from members list
    function removeMultipleFromMembers(address[] memory accounts)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(isMember[accounts[i]], "TNEC: account is not a member");
            isMember[accounts[i]] = false;
        }
    }

    /// @notice set fees, only Owner can call this function
    /// @param _enabled (true or false)
    function setFees(bool _enabled) public onlyOwner {
        feesEnabled = _enabled;
    }

    /// @notice setTNECPercentagesRewards, only Owner can call this function
    /// @param _percentageTNECrewards, percentage to be swapped to tokens
    function setTNECPercentagesRewards(uint256 _percentageTNECrewards)
        public
        onlyOwner
    {
        tokensToSwapPercentage = _percentageTNECrewards;
    }

    /// @notice required to apply the correct fees taxes when buying
    /// @param amountIn, value received and to be dispatched
    /// @return amountOut value to be transfered
    /// @return toRewardsWallet value to be transfered to the staking wallet when buying
    /// @return toBBDDWallet value to be transfered to the BBDD wallet when buying
    /// @return toTresoWallet value to be transfered to the reserve wallet when buying
    /// @return toBurn value to be burn when buying
    function applyFeesBuy(uint256 amountIn)
        public
        view
        returns (
            uint256 amountOut,
            uint256 toRewardsWallet,
            uint256 toBBDDWallet,
            uint256 toTresoWallet,
            uint256 toBurn
        )
    {
        toRewardsWallet = (amountIn * rewardsFeesBuy) / DENOMINATOR;
        toBBDDWallet = (amountIn * BBDDWalletFeesBuy) / DENOMINATOR;
        toTresoWallet = (amountIn * tresoWalletFeesBuy) / DENOMINATOR;
        toBurn = (amountIn * burnFeesBuy) / DENOMINATOR;
        amountOut =
            amountIn -
            (toRewardsWallet + toBBDDWallet + toTresoWallet + toBurn);
    }

    /// @notice required to apply the correct fees taxes when selling
    /// @param amountIn, value received and to be dispatched
    /// @return amountOut value to be transfered
    /// @return toRewardsWallet value to be transfered to the staking wallet when selling
    /// @return toBBDDWallet value to be transfered to the BBDD wallet when selling
    /// @return toTresoWallet value to be transfered to the reserve wallet when selling
    /// @return toBurn value to be burn when selling
    function applyFeesSell(uint256 amountIn)
        public
        view
        returns (
            uint256 amountOut,
            uint256 toRewardsWallet,
            uint256 toBBDDWallet,
            uint256 toTresoWallet,
            uint256 toBurn
        )
    {
        toRewardsWallet = (amountIn * rewardsFeesSell) / DENOMINATOR;
        toBBDDWallet = (amountIn * BBDDWalletFeesSell) / DENOMINATOR;
        toTresoWallet = (amountIn * tresoWalletFeesSell) / DENOMINATOR;
        toBurn = (amountIn * burnFeesSell) / DENOMINATOR;
        amountOut =
            amountIn -
            (toRewardsWallet + toBBDDWallet + toTresoWallet + toBurn);
    }

    ///@notice addLPAddress, add an LP address to LPs. Transferring to an address in `LPs` is considered a sale
    ///@param _newLP, new LP address to add
    function addLPAddress(address _newLP) external onlyOwner {
        require(!LPs[_newLP], "TNEC : already added");
        LPs[_newLP] = true;
    }

    ///@notice removeLPAddress, add an LP address to LPs. Transferring to an address in `LPs` is considered a sale
    ///@param _LP,  LP address to remove
    function removeLPAddress(address _LP) external onlyOwner {
        require(LPs[_LP], "TNEC : not set");
        require(_LP != mainLP, "TNEC : cannot remove main LP");
        LPs[_LP] = false;
    }

    ///@notice pause, Pauses functions modified with `whenNotPaused`, can be called only by owner
    function pause() external virtual whenNotPaused onlyOwner {
        _pause();
    }

    ///@notice  Unpauses functions modified with `whenNotPaused`, can be called only by owner
    function unpause() external virtual whenPaused onlyOwner {
        _unpause();
    }

    ///@notice update the router. Updating the router automatically updates the main LP, can be called only by owner
    ///@param _newRouter, new address to add
    function setRouter(address _newRouter) public onlyOwner {
        require(_newRouter != address(0), "TNEC : cannot be the zero address");
        router = IPancakeRouter02(_newRouter);
        mainLP = IPancakeV2Factory(router.factory()).createPair(
            address(this),
            USDC
        );
        LPs[mainLP] = true;
        _approve(address(this), address(router), type(uint256).max);
        ERC20(USDC).approve(address(router), type(uint256).max);
    }

    ///NB: APPROVE REWARD WALLET
    ///@notice swapAndTransfer, required to swap tokens for USDC and transfer to specific address. Called only by the owner
    ///@param members, list of members for which the distribution will be done (USDC and TNEC)
    ///@param percentages, list of pourcentages for each member (TNEC and USDC)
    function swapAndTransfer(
        address[] calldata members,
        uint256[] calldata percentages
    ) public whenNotPaused onlyOwner {
        uint256 _toTokens = (toRewards * tokensToSwapPercentage) / DENOMINATOR;
        uint256 _amount = toBBDD + toTreso + (toRewards - _toTokens);

        address[] memory _path = new address[](2);

        _path[0] = address(this);
        _path[1] = USDC;

        require(
            members.length == percentages.length,
            "TNEC : Not correct length for members and percentages !"
        );

        // swap and transfer
        if (_amount > 0) {
            uint256 _amountBefore = ERC20(USDC).balanceOf(rewardsWallet);
            _swapTokensForUSDCAndTransfer(_amount, rewardsWallet);
            uint256 _amountAfter = ERC20(USDC).balanceOf(rewardsWallet);

            ERC20(USDC).transferFrom(
                rewardsWallet,
                address(this),
                _amountAfter - _amountBefore
            );
            uint256 amountUSDCswapped = _amountAfter - _amountBefore;

            uint256 _toBBDD = (toBBDD * amountUSDCswapped) / _amount;
            uint256 _toTreso = (toTreso * amountUSDCswapped) / _amount;
            uint256 _toRewards = ((toRewards - _toTokens) * amountUSDCswapped) /
                _amount;

            toBBDD = 0;
            toTreso = 0;
            toRewards = 0;

            // Transfer to BBDD
            ERC20(USDC).transfer(BBDDWallet, _toBBDD);

            // Transfer to treso
            ERC20(USDC).transfer(tresoWallet, _toTreso);

            // distribute USDC and TNEC
            for (uint256 i = 0; i < members.length; i++) {
                ERC20(USDC).transfer(
                    members[i],
                    (_toRewards * percentages[i]) / DENOMINATOR
                );
                super._transfer(
                    address(this),
                    members[i],
                    (_toTokens * percentages[i]) / DENOMINATOR
                );
            }
        }
    }

    /// @notice adds liquidity to the main pool. Liquidity without paying fees taxes
    /// @param amountADesired, The amount of tokenA to add as liquidity if the B/A price is <= amountBDesired/amountADesired (A depreciates).
    /// @param amountBDesired, The amount of tokenB to add as liquidity if the A/B price is <= amountADesired/amountBDesired (B depreciates).
    /// @param amountAMin, Bounds the extent to which the B/A price can go up before the transaction reverts. Must be <= amountADesired.
    /// @param amountBMin, Bounds the extent to which the A/B price can go up before the transaction reverts. Must be <= amountBDesired.
    /// @param to, Recipient of the liquidity tokens.
    /// @param deadline, Unix timestamp after which the transaction will revert.
    function addLiquidityWithoutFees(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external whenNotPaused onlyAuthorized {
        feesEnabled = false;
        // send USDC and TEST from user to the smart contract 
        // need an approve from user before executing this function 
        super._transfer(msg.sender, address(this), amountADesired);
        ERC20(USDC).transferFrom(msg.sender, address(this), amountBDesired);

        router.addLiquidity(
            address(this),
            USDC,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
        feesEnabled = true;
    }

    /// @notice removes liquidity from the main pool. Liquidity without paying fees taxes
    /// @param liquidity, The amount of liquidity tokens to remove
    /// @param amountAMin, The minimum amount of tokenA that must be received for the transaction not to revert
    /// @param amountBMin, The minimum amount of tokenB that must be received for the transaction not to revert
    /// @param to, Recipient of the underlying assets
    /// @param deadline, Unix timestamp after which the transaction will revert
    function removeLiquidityWithoutFees(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external whenNotPaused onlyAuthorized {
        feesEnabled = false;
        // send user's liquidity to the smart contract 
        // need an approve from user before executing this function 
        require(ERC20(mainLP).balanceOf(msg.sender) >= liquidity, "TNEC : You don't have enough liquidity !");
        ERC20(mainLP).transferFrom(msg.sender, address(this), liquidity);
        ERC20(mainLP).approve(address(router), type(uint256).max);
        router.removeLiquidity(
            address(this),
            USDC,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
        feesEnabled = true;
    }

    ///@notice airdropTokens, to airdrop tokens - called only by Owner
    ///@param members, list of members for which the airdrop will be done
    ///@param values, list of values for each member
    function airdropTokens(
        address[] calldata members,
        uint256[] calldata values
    ) public whenNotPaused onlyOwner {
        require(
            members.length == values.length,
            "Not correct length for members and percentages !"
        );

        for (uint256 i = 0; i < members.length; i++) {
            transfer(members[i], values[i]);
        }
    }

    ///@notice burn, destroys `amount` tokens from the caller
    ///@param amount, the amount of tokens to be sent
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        notBlacklisted
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override notBlacklisted returns (bool) {
        uint256 currentAllowance = super.allowance(sender,_msgSender());
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    ///@notice handles the before and after of a token transfer, such as taking fees and firing off a swap and liquify event
    ///@param sender, sender of the transaction
    ///@param recipient, recipient of the transaction
    ///@param amount, the amount of tokens to be sent
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenNotPaused {
        if (!whitelist[sender] && !whitelist[recipient] && feesEnabled) {
            if (LPs[sender]) {
                (
                    uint256 _amountOut,
                    uint256 _toRewardsWallet,
                    uint256 _toBBDDWallet,
                    uint256 _toTresoWallet,
                    uint256 _toBurn
                ) = applyFeesBuy(amount);

                amount = _amountOut;
                super._transfer(
                    sender,
                    address(this),
                    _toRewardsWallet + _toBBDDWallet + _toTresoWallet
                );

                // store how many tokens to swap for usdc and to transfer to reward wallet
                toBBDD += _toBBDDWallet;
                toTreso += _toTresoWallet;
                toRewards += _toRewardsWallet;

                _burn(sender, _toBurn);
            } else if (LPs[recipient]) {
                (
                    uint256 _amountOut,
                    uint256 _toRewardsWallet,
                    uint256 _toBBDDWallet,
                    uint256 _toTresoWallet,
                    uint256 _toBurn
                ) = applyFeesSell(amount);

                amount = _amountOut;
                super._transfer(
                    sender,
                    address(this),
                    _toRewardsWallet + _toBBDDWallet + _toTresoWallet
                );

                // store how many tokens to swap for usdc and to transfer to reward wallet
                toBBDD += _toBBDDWallet;
                toTreso += _toTresoWallet;
                toRewards += _toRewardsWallet;

                // burn some tokens
                _burn(sender, _toBurn);
            }
        }

        super._transfer(sender, recipient, amount);
    }

    ///@notice _addUSDCLiquidity, required to add liquidity to the main LP
    ///@param amount, amount to be added to the LP
    function _addUSDCLiquidity(uint256 amount) internal {
        uint256 toUSDC = amount / 2;
        uint256 amountNativeToken = amount - toUSDC;
        uint256 initialUSDCBalance = ERC20(USDC).balanceOf(address(this));
        _swapTokensForUSDCToThisContract(toUSDC);
        uint256 amountUSDCswapped = ERC20(USDC).balanceOf(address(this)) -
            initialUSDCBalance;

        // add liquidity
        router.addLiquidity(
            address(this),
            USDC,
            amountNativeToken,
            amountUSDCswapped,
            0,
            0,
            address(0),
            1e18 // absurdly high value
        );
    }

    ///@notice _swapTokensForUSDCAndTransfer, required to swap tokens for USDC and transfer to specific address
    ///@param amount, amount to be swaped
    ///@param to, address to receiver the amount swaped
    function _swapTokensForUSDCAndTransfer(uint256 amount, address to)
        internal
    {
        if (amount > 0) {
            address[] memory _path = new address[](2);

            _path[0] = address(this);
            _path[1] = USDC;

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                _path,
                to,
                1e18
            );
        }
    }

    ///@notice _swapTokensForUSDCToThisContract, swap some tokens for USDC and send them to this contract. The function uses two swaps in order
    // to bypass some router limitation. Function is quite inelegant.
    ///@param amount, amount to be swaped
    function _swapTokensForUSDCToThisContract(uint256 amount) internal {
        if (amount > 0) {
            // 1. Swap NOSTA for BNB
            address[] memory _path = new address[](3);
            _path[0] = address(this);
            _path[1] = USDC;
            _path[2] = router.WETH();

            uint256 _BNBBalance = address(this).balance;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                _path,
                address(this),
                1e18
            );

            _BNBBalance = address(this).balance - _BNBBalance;

            // 2. Swap BNB for USDC
            address[] memory _path2 = new address[](2);
            _path2[0] = router.WETH();
            _path2[1] = USDC;
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: _BNBBalance
            }(0, _path2, address(this), 1e18);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;

interface IPancakeV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}