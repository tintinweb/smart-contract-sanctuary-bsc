/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// File: Libraries.sol



pragma solidity 0.8.14;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IPancakeRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: Devov2.sol

//
//
//
//                                                                       #. .../
//                                                                     #...(.....*
//                                                              %####%#/*,/./..%,*%%%%%%#%
//                                                         ###(%%%%%%%%%(/%*/*%#/((%&%%%%%%####.
//                                             ..%%     ##%%%%%%((//////**#(((((***////(((#%#%%%#%%
//                                           # ...,,**(%%%%%(//***(*,,,/*,,,,,,,,,,,///****/((#%#%%%%,...,*,
//                                          #.#%#%/,(#*(#///*****..,,,,,,*****,*,*,,,.,(/(*,***(((%  .##/,/*/
//                                          %/*/(*((%((%**,,,,********,***//*******,,,,,,,********,.,(/.%(/*(%
//          %#(((/(%%%%%%%%*                  /(***/((***,,,,*,******////*(////*****///(/////*,,,*%*/#/,,*/((
//             %%&&%%(*,. ,&&&&&&&&&&&&&&%%%%##%%##//******,***////////*//*//(///***/(//((((//*/,,,**%((((%%%
//        #%&&&&&%%%&&%%%%%%%%%%%%%##...,,,,****%&&.*,****,,,/(#%#%&&&&&&&&&&&&&&&&/(((///(((((*******/((%#%%%%%%%(%#%##%%%%#%%%##%%####%%&&&&&&&%%
//          %%&&.*****,,,....###.,,,,,,,..#%,,,,%%&,***%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&&&&%%&&%%&........&&%%,,,,%&&.,,....&&%#
//             %%&****,,,,,...%%,*,*,,,,,*%%,.,,%&%,,,,&%**,,,,,,..(##... ######**,*&&&....,%,,,,,,,,,,.%%,,,.&&%,,,,,,,,,.&&%,,,,,#&(,,..&&%%
//             %#&****%&&,,,,,%%.,,*%&%%%%%#.,,,%%,,,,%&.,*,#%%.,,,(&(,,..&&##%&,..,%&%,,,..%%%%**,**%%%&&,***#%#,,**%&%**,,&&,,,,,,,%,*,,&%%
//             #&/****%&&,****&%,,.,%%%%#(((,   %% ...%%....%%#.....%%....%&**(&....#&%(...,###&#....##%&&.....&(..,,%%&****&% ,,,,,,*****&%%
//            (%&.,*,*%%%....%%   .......%%&    #,   ,%%   .%%&....,%%....&&**/&    (&%#....&&&&%  ..&&%%%.....%%    &&&....,%%   %  .....&&%
//            %%&    ,%%#....%%    %%%%%%%%%    #    %%%    %#& ...##&    &&**/&    .&%* ...&#&%%    &&%%%/    %%    #%%/ ...%%    &%     .&%%
//            /&%    ###    .##    %%%%#((((        ,##%    %%&    #%%    &&/*/&     &%*    &#&%%    %&%%%&    #%     ##.    %%    %%%     &%%
//            %&             %(         %%&&        ###&           %%          &            &(&##    #&&###    %%#           ##    %%%%    %&%
//           %%&           *%%          %%%%        ###&&.       .%%&.         &%%        #&((&##    ,&&###    %%%&          ##.   ,####(   &%#
//           (%&%%%%%%%%%%%%%%##%%%%%%%%%###&      %%##&(&&########%&&#########&&(########&(*/&#####%&%&###%%%&###%%%%%%%%#####%%%##(((###%#&%%
//             %%%%&&&&&&&&&&&&&&&&&&&&&&&&&&&   (%%%%&#,,*#%&&&&%%#/#%%%%%#####(%%#####%#(**/###%%%(/%&&&&&&%&&&&&&&&&&&&&&&&&&&&&&&&&&&&%%%
//                   %%%%%%%%/              %%& ####&&#**,,////*/////*****//*/*********/***,*,,******(#%#%(#       ##*      /#%   %%%%%
//                                           %%%&&#&&&**,,*,(/((((/***///****/**********,,,,,,,,,**/#%(%%%%
//                                               %%&#%%%/***,,,*/////**************,*,,,*((//////(###%#%%
//                                                  %#%%%%%(*****,,,,,/*******,,,.,,,(/(//**//(#%(###%,
//                                                     %%%#%%%%(//***,**,,,,,/(*,,,,*/////(#%###%##%
//                                                        *#%%%%%%#%%((/*, .,,,,*%((##%%###%%%%%
//                                                             %%###%%%%,/,,.,,*(//%%%%%%%%#
//                                                                     #/*/(*/((///
//                                                                      %//////(((
//                                                                           ,.
//
//
//www.devolution-world.com
//
//https://twitter.com/Game_Devolution
//
//https://t.me/DevolutionOfficial
//
//https://www.instagram.com/devolutionofficial/


pragma solidity 0.8.14;


contract Devolution is IBEP20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    //Accounts excluded from all transfer restrictions and fees
    mapping(address => bool) public excluded;
    //Automated Market Makers, buy and sell taxes apply to transfers with them
    mapping(address => bool) public isAMM;
    //For Front run protection
    mapping(address => uint256) public lastBuyBlock;
    //Token Info
    string public constant name = "D2";
    string public constant symbol = "D2";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 10**9 * 10**decimals; //equals 1.000.000.000 Token


    //TestNet
    address private constant PancakeRouter=0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //MainNet
    //address private constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //Taxes
    uint256 public buyTax = 50;
    uint256 public sellTax = 50;
    uint256 public transferTax = 0;
    uint256 public liquidityTax = 300;
    uint256 public operationsTax = 400;
    uint256 public buybackTax = 300;
    uint256 constant TAX_DENOMINATOR = 1000;
    uint256 public constant MAX_TAX = 100;

    //Owner wallets
    address public operationsWallet;
    address public buybackWallet;

    //Setting variables
    uint256 public overLiquifyThreshold = (totalSupply * 150) / 1000; //15%
    uint256 public LaunchTimestamp;
    uint256 public liquidityUnlockTime;
    uint256 public swapThreshold = 2;
    bool public autoLiquify = true;
    bool public frontRunProtection = false; //only need frontRunProtection if 0 Tax;


    //Main Router
    address private _pair;
    IPancakeRouter private _router;

    //Events for owner interactions
    event OnSetSwapThreshold(uint256 newTgreshold);
    event OnSetOverLiquifyThreshold(uint256 newThreshold);
    event OnSetTaxes(
        uint256 buy,
        uint256 sell,
        uint256 transfer_,
        uint256 buyback,
        uint256 operations,
        uint256 liquidity
    );
    event OnChangeAMM(address AMM, bool flag);
    event OnSwitchAutoLiquify(bool flag);
    event OnSetExclusion(address account, bool flag);
    event OnEnableTrading();
    event OnProlongLPLock(uint256 UnlockTimestamp);
    event OnReleaseLP();
    event OnSetOperationsWallet(address wallet);
    event OnSetBuybackWallet(address wallet);
    event OnSetFrontrunProtection(bool flag);
    event OnRescueTokens(address token);

    //Modifier so only one Liquify can happen at a time
    bool private _isSwappingContractModifier;
    modifier lockTheSwap() {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    constructor() {
        address Multisig = msg.sender; //TODO: Hardcode Multisig
        _balances[Multisig] = totalSupply;
        emit Transfer(address(0), Multisig, totalSupply);

        _router = IPancakeRouter(PancakeRouter);
        //Creates a Pancake Pair
        _pair = IPancakeFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        isAMM[_pair] = true;

        //multisig is the default wallet and wallets need to be set later
        operationsWallet = Multisig;
        buybackWallet = Multisig;
        //owner pancake router and contract is excluded from Taxes
        excluded[Multisig] = true;
        excluded[PancakeRouter] = true;
        excluded[address(this)] = true;
        _approve(address(this), address(_router), type(uint256).max);
        transferOwnership(Multisig);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Token Implementation//////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //transfer functions
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");

        //Pick transfer
        if (excluded[sender] || excluded[recipient])
            _feelessTransfer(sender, recipient, amount);
        else {
            //once trading is enabled, it can't be turned off again
            require(LaunchTimestamp > 0, "trading not yet enabled");
            _taxedTransfer(sender, recipient, amount);
        }
    }

    function _taxedTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        bool isBuy = isAMM[sender];
        bool isSell = isAMM[recipient];

        uint256 tax;
        if (isSell) {
            if (frontRunProtection)
                require(
                    lastBuyBlock[sender] != block.number,
                    "Frontrun protection engaged"
                );
            tax = sellTax;
        } else if (isBuy) {
            if (frontRunProtection) lastBuyBlock[recipient] = block.number;
            tax = buyTax;
        } else {
            if (frontRunProtection)
                require(
                    lastBuyBlock[sender] != block.number,
                    "Frontrun protection engaged"
                );
            tax = transferTax;
        }

        if ((sender != _pair) && autoLiquify && (!_isSwappingContractModifier))
            _liquify((_balances[_pair] * swapThreshold) / TAX_DENOMINATOR);

        uint256 contractToken = (amount * tax) / TAX_DENOMINATOR;

        _balances[sender] -= amount;
        if (contractToken > 0) {
            amount -= contractToken;
            _balances[address(this)] += contractToken;
            emit Transfer(sender, address(this), contractToken);
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _feelessTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    //Approve functions
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //liquify functions
    function _liquify(uint256 tokenToSwap) private lockTheSwap {
        uint256 contractBalance = _balances[address(this)];
        if (tokenToSwap > contractBalance) return;
        if (tokenToSwap == 0) return;

        uint256 tokenForLiquidity = isOverLiquified()
            ? 0
            : (tokenToSwap * liquidityTax) / TAX_DENOMINATOR;

        uint256 tokenForBNB = tokenToSwap - tokenForLiquidity;

        uint256 LiqHalf = tokenForLiquidity / 2;
        uint256 swapToken = LiqHalf + tokenForBNB;
        _swapTokenForBNB(swapToken);
        uint256 newBNB = address(this).balance;

        if (LiqHalf > 0) {
            uint256 liqBNB = (newBNB * LiqHalf) / swapToken;
            _addLiquidity(LiqHalf, liqBNB);
        }
        _sendBNB();
    }

    //Sends BNB from the contract to the wallets
    function _sendBNB() private {
        uint256 totalTax = operationsTax + buybackTax;
        bool sent;
        if (totalTax > 0) {
            (sent, ) = buybackWallet.call{
                value: (address(this).balance * buybackTax) / totalTax
            }("");
        }
        //If both taxes are 0 operations wallet will receive everything
        (sent, ) = operationsWallet.call{value: address(this).balance}("");
    }

    function _swapTokenForBNB(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        try
            _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}
    }

    function _addLiquidity(uint256 tokenamount, uint256 bnbamount) private {
        _router.addLiquidityETH{value: bnbamount}(
            address(this),
            tokenamount,
            0, //No need for slippage as frontrun protection or tax alleviates the risk of sandwich attacks
            0,
            address(this),
            block.timestamp
        );
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Owner functions///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function ChangeOperationsWallet(address newWallet) external onlyOwner {
        operationsWallet = newWallet;
        emit OnSetOperationsWallet(newWallet);
    }

    function ChangeBuybackWallet(address newWallet) external onlyOwner {
        buybackWallet = newWallet;
        emit OnSetBuybackWallet(newWallet);
    }

    function setFrontRunProtection(bool flag) public onlyOwner {
        if (frontRunProtection == flag) return;
        frontRunProtection = flag;
        emit OnSetFrontrunProtection(flag);
    }

    function setSwapThreshold(uint256 newSwapThreshold) external onlyOwner {
        require(newSwapThreshold <= 10); //MaxThreshold= 1%
        require(newSwapThreshold > 0);
        swapThreshold = newSwapThreshold;
        emit OnSetSwapThreshold(newSwapThreshold);
    }

    function SetOverLiquifiedThreshold(uint256 newOverLiquifyThreshold)
        external
        onlyOwner
    {
        require(newOverLiquifyThreshold <= TAX_DENOMINATOR);
        overLiquifyThreshold =
            (totalSupply * newOverLiquifyThreshold) /
            TAX_DENOMINATOR;
        emit OnSetOverLiquifyThreshold(newOverLiquifyThreshold);
    }

    function SetTaxes(
        uint256 buy,
        uint256 sell,
        uint256 transfer_,
        uint256 buyback,
        uint256 operations,
        uint256 liquidity
    ) external onlyOwner {
        require(
            buy <= MAX_TAX && sell <= MAX_TAX && transfer_ <= MAX_TAX,
            "Tax exceeds max Tax"
        );
        require(
            buyback + operations + liquidity == TAX_DENOMINATOR,
            "Taxes don't add up to denominator"
        );
        //At 4% or below combined tax auto enable frontRunProtection
        if (buyTax + sellTax <= 40) setFrontRunProtection(true);
        else setFrontRunProtection(false);
        buyTax = buy;
        sellTax = sell;
        transferTax = transfer_;
        operationsTax = operations;
        liquidityTax = liquidity;
        buybackTax = buyback;
        emit OnSetTaxes(buy, sell, transfer_, buyback, operations, liquidity);
    }

    function SetAMM(address AMM, bool flag) external onlyOwner {
        require(AMM != _pair, "can't change pancake");
        isAMM[AMM] = flag;
        emit OnChangeAMM(AMM, flag);
    }

    function SwitchManualSwap(bool flag) public onlyOwner {
        autoLiquify = flag;
        emit OnSwitchAutoLiquify(flag);
    }

    function SetExclusion(address account, bool flag) external onlyOwner {
        require(account != address(this), "can't Include the contract");
        excluded[account] = flag;
        emit OnSetExclusion(account, flag);
    }

    function EnableTrading() external onlyOwner {
        require(LaunchTimestamp == 0, "AlreadyLaunched");
        LaunchTimestamp = block.timestamp;
        emit OnEnableTrading();
    }

    function TriggerLiquify() external onlyOwner {
        _liquify(_balances[address(this)]);
    }

    function LockLiquidityForSeconds(uint256 secondsUntilUnlock)
        external
        onlyOwner
    {
        uint256 newUnlockTime = secondsUntilUnlock + block.timestamp;
        require(newUnlockTime > liquidityUnlockTime);
        liquidityUnlockTime = newUnlockTime;
        emit OnProlongLPLock(liquidityUnlockTime);
    }

    function LiquidityRelease() external onlyOwner {
        require(block.timestamp >= liquidityUnlockTime, "Not yet unlocked");
        IBEP20 liquidityToken = IBEP20(_pair);
        uint256 amount = liquidityToken.balanceOf(address(this));
        liquidityToken.transfer(msg.sender, amount);
        emit OnReleaseLP();
    }

    function RescueTokens(address token) external onlyOwner {
        require(token != address(this) && token != _pair, "Forbidden Token");
        IBEP20 Token = IBEP20(token);
        uint256 amount = Token.balanceOf(address(this));
        Token.transfer(msg.sender, amount);
        emit OnRescueTokens(token);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //view Functions////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    function isOverLiquified() public view returns (bool) {
        return _balances[_pair] > overLiquifyThreshold;
    }

    function getLiquidityReleaseTimeInSeconds()
        external
        view
        returns (uint256)
    {
        if (block.timestamp < liquidityUnlockTime)
            return liquidityUnlockTime - block.timestamp;
        return 0;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address _owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    //Can only receive from pancake router to avoid accidentally sending BNB
    receive() external payable {
        require(msg.sender == PancakeRouter, "Can only receive from router");
    }
}