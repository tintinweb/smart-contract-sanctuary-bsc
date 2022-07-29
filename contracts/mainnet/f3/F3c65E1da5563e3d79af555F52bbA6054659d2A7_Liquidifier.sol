// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TransferHelper.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswap.sol";
import "./IMasterChef.sol";
import "./IPancakePair.sol";
import "./IVault.sol";
import "./Operations.sol";
import "./IOracle.sol";
import "./ILiquidation.sol";

contract Liquidifier is AccessControl, ReentrancyGuard, Operations {

    ///@dev events
    event addETH(
        address indexed _user,
        uint256 _position,
        uint256 _lpamount,
        uint256 _cakeamount
    );
    event increaseETH(
        address indexed _user,
        uint256 _position,
        uint256 _lpamount,
        uint256 _cakeamount
    );
    event removeETH(
        address indexed _user,
        uint256 _position,
        uint256 _lpamount,
        uint256 _cakeamount
    );
    event removepartialETH(
        address indexed _user,
        uint256 _position,
        uint256 _lpamount,
        uint256 _cakeamount
    );

    event positionLiquidated(
        address indexed wallet,
        uint256 _id,
        uint256 liqPrice,
        uint256 useramount,
        uint256 _penalty
    );

    ///@dev developer role created
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");

    ///@dev contract constants to interact with the dex
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
    address internal constant UNISWAP_FACTORY_ADDRESS =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; //mainnet
    address internal constant MASTERCHEF_ADDRESS =
        0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652; //mainnet
    address internal constant WBNB_ADDRESS =
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //mainnet
    address internal constant CAKE_ADDRESS =
        0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82; //mainnet
    address internal constant TENESSE_POLL =
        0x224c764610AB246aE7a6262649057358A9f05b05; //mainnet

    address public Vault;
    IVault public vault;
    IUniswap public dex;
    IMasterChef public masterchef;
    address public _Liquidation;
    ILiquidation internal liquidation;
    IOracle internal oracle;

    //Id for open positions
    uint256 public positionsId = 0;

    //Position record
    mapping(uint256 => address) public openPositions;

    //Structure to store local variables and avoid stack too deep error
    struct LiquidifierLocalVars {
        uint256 lptokens;
        uint256 _userfunds;
        uint256 _treasury;
        uint256 _cake;
        uint256 _user;
        uint256 _debt;
        uint256 balanceBefore;
        uint256 tokenamount;
        uint256 ETHamount;
        uint256 liquidity;
        uint256 balanceAfter;
        uint256 _liqPrice;
        uint256 _reward;
        uint256 vaul;
        address wallet;
        uint256 busdvalue;
        uint256 rewardUser;
        uint256 rewardLiquidifier;
        uint256 reward;
        uint256 bnbamount;
    }

    ///@notice structure and mapping that keeps track of customer's LPs and pools
    struct RegisterLP {
        uint256 lp;
        uint256 reward;
        bool farming;
        uint256 liqPrice;
        bool liqStatus;
    }

    mapping(address => mapping(address => RegisterLP)) private userinvestment;

    ///@notice structure and mapping that keeps track of customer deposit
    ///@notice Stores user's deposits and loans
    ///@param firstToken address of first token for pool
    ///@param secondToken address of the second token for the pool token to token to token

    struct RegisterDeposit {
        uint256 loan; //BUSD
        uint256 deposit; //BNB or a token with volatility
        address firstToken;
        address secondToken;
    }

    mapping(address => mapping(uint256 => RegisterDeposit)) private userdeposit;

    ///@dev register of pools used by farmcontrol
    mapping(address => uint256) public poolinfo;

    constructor(address _vault, address _liquidation, address _oracle) {
        Vault = _vault;
        vault = IVault(Vault);
        _Liquidation = _liquidation;
        liquidation = ILiquidation(_Liquidation);
        dex = IUniswap(UNISWAP_ROUTER_ADDRESS);
        masterchef = IMasterChef(MASTERCHEF_ADDRESS);
        oracle = IOracle(_oracle);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEV_ROLE, msg.sender);

        poolinfo[0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16] = 3; //BNB-BUSD pool
        poolinfo[0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82] = 39; //CaKe-BUSD pool
        TransferHelper.safeApprove(
            0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16, //BNB-BUSD pool
            address(masterchef),
            type(uint256).max //esto es el maximo en UINT256 o sustituir por 100000000000000000000
        ); //mainnet

        TransferHelper.safeApprove(
            CAKE_ADDRESS,
            address(masterchef),
            type(uint256).max //esto es el maximo en UINT256 o sustituir por 100000000000000000000
        ); //mainnet

        TransferHelper.safeApprove(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, //BUSD Address
            UNISWAP_ROUTER_ADDRESS,
            type(uint256).max
        );

        TransferHelper.safeApprove(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, //BUSD Address
            address(Vault),
            type(uint256).max
        );

        TransferHelper.safeApprove(
            CAKE_ADDRESS,
            UNISWAP_ROUTER_ADDRESS,
            type(uint256).max //esto es el maximo en UINT256 o sustituir por 100000000000000000000
        ); //mainnet
    }

    modifier isLiquidated(uint256 _position, address _lp) {
        verifyLiqStatus(_position, _lp);
        if (userinvestment[msg.sender][_lp].liqStatus) {
            revert("liquidated Position");
        }
        _;
    }

    ///@notice function to withdraw tokens of the contract
    ///@dev only wallet with admin role can withdraw the tokens
    function withdrawToken(address _tokenContract) external {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert("have no admin role");
        }
        uint256 balance = IERC20(_tokenContract).balanceOf(address(this));
        TransferHelper.safeTransfer(_tokenContract, msg.sender, balance);
    }

    ///@notice function to withdraw BNB of the contract
    ///@dev only wallet with admin role can withdraw the BNB
    function withdrawBNB() external {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert("have no admin role");
        }
        uint256 balance = address(this).balance;
        TransferHelper.safeTransferETH(msg.sender, balance);
    }

    ///@notice This function helps to make add liquidity to pools in pancakeswap and
    ///@notice receive the corresponding LP tokens
    function addLiqETH(address token, uint256 loanamount)
        external
        payable
        returns (uint256 lp, uint256 treasury)
    {
        address LP = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS).getPair(
            WBNB_ADDRESS,
            token
        );

        if (userinvestment[msg.sender][LP].lp != 0) {
            revert("have a position open");
        }

        LiquidifierLocalVars memory vars;

        vars.balanceBefore = address(this).balance;

        //The BNB is transferred to the contract in order to deposit it and open the position.
        TransferHelper.safeTransferETH(address(this), msg.value);
        //The loan is taken from the vault
        vault.withdraw(loanamount);

        ++positionsId;

        (vars.tokenamount, vars.ETHamount, vars.liquidity) = dex
            .addLiquidityETH{value: msg.value}(
            token,
            loanamount,
            0, //Minimum amount of ETH expected to be received
            0, //Minimum amount of tokens expected to be received
            address(this),
            block.timestamp
        );

        vars.balanceAfter = address(this).balance;

        if (vars.balanceAfter != 0) {
            vars._userfunds = vars.balanceBefore - vars.ETHamount;
            TransferHelper.safeTransferETH(msg.sender, vars._userfunds);
        }

        vars._liqPrice = liquidation.liquidationPrice(poolinfo[LP], 50);

        userinvestment[msg.sender][LP].lp = vars.liquidity;
        userinvestment[msg.sender][LP].liqPrice = vars._liqPrice;
        userdeposit[msg.sender][positionsId].loan = vars.tokenamount;
        userdeposit[msg.sender][positionsId].deposit = vars.ETHamount;
        userdeposit[msg.sender][positionsId].firstToken = token;

        openPositions[positionsId] = msg.sender;

        ///Deposited to the farm to generate rewards
        depositFarm(LP, vars.liquidity);

        //Rewards are updated
        vars._reward = Operations.rewardsRegistry(
            MASTERCHEF_ADDRESS,
            userinvestment[msg.sender][LP].lp,
            poolinfo[LP]
        );

        liquidation.addPosition(positionsId);

        userinvestment[msg.sender][LP].reward = vars._reward;
        userinvestment[msg.sender][LP].farming = true;

        (vars.vaul, vars._cake) = transferToTreasury(token);

        lp = userinvestment[msg.sender][LP].lp;

        emit addETH(msg.sender, positionsId, vars.liquidity, vars._cake);

        return (lp, vars.vaul);
    }

    ///@notice This function helps to increase liquidity in the position and
    ///@notice receive the corresponding LP tokens
    function increaseLiqETH(
        address token,
        uint256 loanamount,
        uint256 _position,
        address LP
    )
        external
        payable
        isLiquidated(_position, LP)
        returns (uint256 lp, uint256 treasury)
    {
        LiquidifierLocalVars memory vars;

        if (openPositions[_position] != msg.sender) {
            revert("not the owner position");
        }
        vars.balanceBefore = address(this).balance;

        //The BNB is transferred to the contract in order to deposit it and open the position.
        TransferHelper.safeTransferETH(address(this), msg.value);
        //The loan is taken from the vault
        vault.withdraw(loanamount);

        (vars.tokenamount, vars.ETHamount, vars.liquidity) = dex
            .addLiquidityETH{value: msg.value}(
            token,
            loanamount,
            0, //Minimum amount of ETH expected to be received
            0, //Minimum amount of tokens expected to be received
            address(this),
            block.timestamp
        );

        vars.balanceAfter = address(this).balance;

        if (vars.balanceAfter != 0) {
            vars._userfunds = vars.balanceBefore - vars.ETHamount;
            TransferHelper.safeTransferETH(msg.sender, vars._userfunds);
        }

        vars.lptokens = userinvestment[msg.sender][LP].lp;

        userinvestment[msg.sender][LP].lp = vars.lptokens + vars.liquidity;
        userdeposit[msg.sender][_position].loan =
            userdeposit[msg.sender][_position].loan +
            vars.tokenamount;
        userdeposit[msg.sender][_position].deposit =
            userdeposit[msg.sender][_position].deposit +
            vars.ETHamount;
        updateLiqPrice(50, LP);
        ///Deposited to the farm to generate rewards
        depositFarm(LP, vars.liquidity);

        //Rewards are updated
        vars._reward = Operations.rewardsRegistry(
            MASTERCHEF_ADDRESS,
            userinvestment[msg.sender][LP].lp,
            poolinfo[LP]
        );

        userinvestment[msg.sender][LP].reward = vars._reward;

        (vars.vaul, vars._cake) = transferToTreasury(token);

        lp = vars.lptokens;

        emit increaseETH(msg.sender, _position, vars.liquidity, vars._cake);

        return (lp, vars.vaul);
    }

    ///@notice This function helps to make remove liquidity from pools in pancakeswap and
    ///@notice brun the corresponding LP tokens
    ///@param amountlp is the amount of LP you wish to withdraw from the pool
    function removeliquidityETH(
        address token,
        uint256 amountlp,
        uint256 _position,
        address LP
    )
        external
        isLiquidated(_position, LP)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 _rewards
        )
    {
        LiquidifierLocalVars memory vars;

        if (amountlp < userinvestment[msg.sender][LP].lp) {
            revert("full withdrawal");
        }

        if (
            IERC20(LP).allowance(address(this), UNISWAP_ROUTER_ADDRESS) <
            amountlp
        ) {
            TransferHelper.safeApprove(
                LP,
                UNISWAP_ROUTER_ADDRESS,
                100000000000000000000
            );
        }

        vars.lptokens = userinvestment[msg.sender][LP].lp;
        vars._debt = userinvestment[msg.sender][LP].reward;

        if (vars.lptokens == 0) {
            revert("no lp");
        }

        ///Withdraw from LP farm and rewards
        withdrawFarm(LP, amountlp);

        ///Withdraw the liquidity to the user and return the loan.
        (amountToken, amountETH) = dex.removeLiquidityETH(
            token,
            amountlp,
            0,
            0,
            address(this),
            block.timestamp
        );

        userinvestment[msg.sender][LP].lp = 0;

        userinvestment[msg.sender][LP].reward = 0;

        userinvestment[msg.sender][LP].farming = false;
        userinvestment[msg.sender][LP].liqPrice = 0;

        userinvestment[msg.sender][LP].liqStatus = false;

        (vars._userfunds, vars._treasury) = loanCalculation(
            LP,
            token,
            amountToken,
            amountETH,
            _position,
            block.timestamp
        );

        depositCalculation(vars._userfunds, vars._treasury);

        userdeposit[msg.sender][_position].loan = 0;
        userdeposit[msg.sender][_position].deposit = 0;
        openPositions[_position] = address(0);

        (, vars._cake) = transferToTreasury(token);

        vars._user = transferrewards(
            msg.sender,
            LP,
            token,
            amountETH,
            amountToken,
            vars.lptokens,
            vars._debt
        );

        liquidation.deletePosition(_position);

        _rewards = vars._user;

        emit removeETH(msg.sender, _position, amountlp, vars._cake);
    }

    ///@notice This function helps to partially remove the liquidity of the pools in pancakeswap and
    ///@notice brun the corresponding LP tokens
    ///@param amountlp is the amount of LP you wish to withdraw from the pool
    function partiallyRemoveLiquidityETH(
        address token,
        uint256 amountlp,
        uint256 _loanamount, //BUSD to be withdrawn by the customer
        uint256 _position,
        address LP
    )
        external
        isLiquidated(_position, LP)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 _rewards
        )
    {
        LiquidifierLocalVars memory vars;

        vars.lptokens = userinvestment[msg.sender][LP].lp;

        if (amountlp >= vars.lptokens) {
            revert("partial withdrawal");
        }

        if (vars.lptokens == 0) {
            revert("no lp");
        }

        if (
            IERC20(LP).allowance(address(this), UNISWAP_ROUTER_ADDRESS) <
            amountlp
        ) {
            TransferHelper.safeApprove(
                LP,
                UNISWAP_ROUTER_ADDRESS,
                100000000000000000000
            );
        }

        withdrawFarm(LP, amountlp);

        ///Withdraw the liquidity to the user and return the loan.
        (amountToken, amountETH) = dex.removeLiquidityETH(
            token,
            amountlp,
            0,
            0,
            address(this),
            block.timestamp
        );

        userinvestment[msg.sender][LP].lp = vars.lptokens - amountlp;
        updateLiqPrice(50, LP);

        (vars._userfunds, vars._treasury) = partialloanCalculation(
            LP,
            token,
            amountToken,
            amountETH,
            _loanamount
        );

        depositCalculation(vars._userfunds, vars._treasury);

        userdeposit[msg.sender][_position].loan =
            userdeposit[msg.sender][_position].loan -
            amountToken;
        userdeposit[msg.sender][_position].deposit =
            userdeposit[msg.sender][_position].deposit -
            amountETH;

        (, vars._cake) = transferToTreasury(token);

        vars._user = transferrewards(
            msg.sender,
            LP,
            token,
            amountETH,
            amountToken,
            vars.lptokens,
            userinvestment[msg.sender][LP].reward
        );

        //Update user rewards
        userinvestment[msg.sender][LP].reward = registryRewards(
            MASTERCHEF_ADDRESS,
            userinvestment[msg.sender][LP].lp,
            poolinfo[LP]
        );

        _rewards = vars._user;

        emit removepartialETH(msg.sender, _position, amountlp, vars._cake);
    }

    function updateLiqPrice(uint256 _debt, address _lp) internal {
        uint256 _id = poolinfo[_lp];
        uint256 _liqprice = liquidation.liquidationPrice(_id, _debt);
        bool _state = liquidation.liquidationState(_liqprice, _id);
        userinvestment[msg.sender][_lp].liqPrice = _liqprice;
        userinvestment[msg.sender][_lp].liqStatus = _state;
    }

    function loanCalculation(
        address _lp,
        address token,
        uint256 amountToken,
        uint256 amountETH,
        uint256 _position,
        uint256 deadline
    ) internal returns (uint256 _userfunds, uint256 _treasury) {
        uint256 _loan = userdeposit[msg.sender][_position].loan;

        (uint256 amountA, uint256 amountB) = Operations.orderAmount(
            _loan,
            amountToken
        );

        uint256 _amountBnb;
        uint256 _amountBusd;
        if (_loan > amountToken) {
            //swap BNB to BUSD
            (_amountBnb, _amountBusd) = makeaSwapETH(
                _lp,
                amountA,
                amountB,
                token,
                deadline
            );
            _userfunds = amountETH - _amountBnb;
            _treasury = amountToken + _amountBusd;
        } else if (_loan < amountToken) {
            (_amountBusd) = makeaSwapToken(amountA, amountB, token);
            _userfunds = amountETH;
            _treasury = amountToken - _amountBusd;
        } else {
            _userfunds = amountETH;
            _treasury = amountToken;
        }

        return (_userfunds, _treasury);
    }

    function partialloanCalculation(
        address _lp,
        address token,
        uint256 amountToken,
        uint256 amountETH,
        uint256 _loanamount
    ) internal returns (uint256 _userfunds, uint256 _treasury) {
        (uint256 amountA, uint256 amountB) = Operations.orderAmount(
            _loanamount,
            amountToken
        );

        uint256 _amountBnb;
        uint256 _amountBusd;
        if (_loanamount > amountToken) {
            (_amountBnb, _amountBusd) = makeaSwapETH(
                _lp,
                amountA,
                amountB,
                token,
                block.timestamp
            );
            _userfunds = amountETH - _amountBnb;
            _treasury = amountToken + _amountBusd;
        } else if (_loanamount < amountToken) {
            (_amountBusd) = makeaSwapToken(amountA, amountB, token);
            _userfunds = amountETH;
            _treasury = amountToken - _amountBusd;
        } else {
            _userfunds = amountETH;
            _treasury = amountToken;
        }

        return (_userfunds, _treasury);
    }

    function depositCalculation(uint256 _amountETH, uint256 _amounToken)
        internal
    {
        //Transfer to the user
        TransferHelper.safeTransferETH(msg.sender, _amountETH);
        //Transfer to the vault
        vault.deposit(_amounToken);
        //TransferHelper.safeTransfer(token, address(vault), amounToken);
    }

    function depositFarm(address _pool, uint256 _lpamount)
        internal
        nonReentrant
    {
        uint256 id = poolinfo[_pool];
        masterchef.deposit(id, _lpamount);
    }

    function withdrawFarm(address _pool, uint256 _lpamount)
        internal
        nonReentrant
    {
        uint256 id = poolinfo[_pool];
        masterchef.withdraw(id, _lpamount);
    }

    function transferrewards(
        address _to,
        address _lp,
        address token,
        uint256 _ethAmount,
        uint256 amountToken,
        uint256 _lpamount,
        uint256 _debt
    ) internal nonReentrant returns (uint256 _user) {
        uint256 _id = poolinfo[_lp];

        //BNB value calculation in BUSD
        (uint256 percentageUser, uint256 percentageLoan) = Operations.bnbtoBusd(
            oracle.getLatestPrice(_id),
            _ethAmount,
            amountToken
        );

        uint256 _rewards = Operations.cakeCalculation(
            MASTERCHEF_ADDRESS,
            _id,
            _lpamount,
            _debt
        );
        uint256 rewardUser = 0;
        if (_rewards != 0) {
            //Cake value calculation in BUSD
            rewardUser = cakeDistribution(
                token,
                _to,
                _rewards,
                percentageUser,
                percentageLoan
            );
        }

        return rewardUser;
    }

    function cakeDistribution(
        address _token,
        address _to,
        uint256 _rewards,
        uint256 percentageUser,
        uint256 percentageLoan
    ) internal returns (uint256 reward) {
        (uint256 liquidity1, uint256 liquidity2) = Operations.reserves(
            0x804678fa97d91B974ec2af3c843270886528a9E6
        );

        uint256 busdvalue = dex.getAmountOut(_rewards, liquidity1, liquidity2);

        uint256 rewardUser = (busdvalue * (percentageUser)) / 100000;

        uint256 rewardLiquidifier = (busdvalue * (percentageLoan)) / 100000;

        vault.withdraw(rewardUser);
        vault.addReward(rewardLiquidifier);

        (reward, ) = Operations.makeaSwapPanom(
            address(dex),
            _token,
            rewardUser
        );
        //Transfer to the user
        TransferHelper.safeTransfer(
            0x5430A9E06E2dcc4Fc2760522057fb46128AE463f,
            _to,
            reward
        );

        return reward;
    }

    function transferToTreasury(address token)
        internal
        returns (uint256 treasury, uint256 _cake)
    {
        (treasury, _cake) = Operations.makeaSwapCake(
            address(dex),
            CAKE_ADDRESS,
            token
        );
        if (treasury != 0) {
            //TransferHelper.safeTransfer(token, address(vault), treasury);
            vault.deposit(treasury);
        }
    }

    function makeaSwapETH(
        address _lp,
        uint256 amountA,
        uint256 amountB,
        address token,
        uint256 deadline
    ) internal returns (uint256 _amountBnb, uint256 _amountBusd) {
        (uint256 reserve1, uint256 reserve2) = Operations.reserves(_lp);

        uint256 diference = amountA - amountB;

        _amountBnb = dex.getAmountIn(diference, reserve1, reserve2);

        address[] memory path = Operations.makePath(WBNB_ADDRESS, token);
        uint256[] memory amounts = dex.swapExactETHForTokens{value: _amountBnb}(
            0,
            path,
            address(this),
            deadline
        );

        return (_amountBnb, amounts[1]);
    }

    function makeaSwapToken(
        uint256 amountA,
        uint256 amountB,
        address token
    ) internal returns (uint256 _busdAmount) {
        (uint256 reserve1, uint256 reserve2) = Operations.reserves(
            TENESSE_POLL
        );

        uint256 diference = amountA - amountB;

        _busdAmount = dex.getAmountIn(diference, reserve1, reserve2);

        (uint256 _panom, uint256 _busd) = Operations.makeaSwapPanom(
            address(dex),
            token,
            _busdAmount
        );
        TransferHelper.safeTransfer(
            0x5430A9E06E2dcc4Fc2760522057fb46128AE463f,
            msg.sender,
            _panom
        );

        return _busd;
    }

    function registryRewards(
        address _chef,
        uint256 _lpamount,
        uint256 _poolinfo
    ) internal view returns (uint256 _rewards) {
        _rewards = Operations.rewardsRegistry(_chef, _lpamount, _poolinfo);
    }

    function verifyLiqStatus(uint256 _id, address _lp) public {
        address _user = openPositions[_id];
        if (userinvestment[_user][_lp].farming) {
            (, , , uint256 liqprice, ) = getUserInvestment(_user, _lp);
            bool status = liquidation.liquidationState(liqprice, 3);
            if (status) {
                userinvestment[_user][_lp].liqStatus = true;
                liquidation.deletePosition(_id);
            }
        }
    }

    function returnLiquidationPosition()
        public
        view
        returns (uint256[] memory liqpositions)
    {
        uint256 count;
        for (uint256 i = 1; i <= positionsId; ) {
            address _user = openPositions[i];
            if (
                userinvestment[_user][
                    0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
                ].farming &&
                userinvestment[_user][
                    0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
                ].liqStatus
            ) {
                ++count;
            }
            unchecked {
                ++i;
            }
        }
        uint256 _index = 0;
        liqpositions = new uint256[](count);
        for (uint256 i = 1; i <= positionsId; ) {
            address _user = openPositions[i];

            if (
                userinvestment[_user][
                    0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
                ].liqStatus
            ) {
                liqpositions[_index] = i;
                ++_index;
            }
            unchecked {
                ++i;
            }
        }
        return liqpositions;
    }

    function executeliquidation(uint256 _id, bytes32[] calldata _merkleProof)
        public
        returns (uint256 penalty)
    {
        LiquidifierLocalVars memory vars;
        vars.wallet = openPositions[_id];
        if (
            !userinvestment[vars.wallet][
                0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
            ].liqStatus
        ) {
            revert("can not liquidate");
        }
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        if (!liquidation.verifyMerkle(_merkleProof, leaf, _id)) {
            revert("Fake Proof");
        }

        vars.lptokens = userinvestment[vars.wallet][
            0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
        ].lp;

        if (
            IERC20(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16).allowance(
                address(this),
                UNISWAP_ROUTER_ADDRESS
            ) < vars.lptokens
        ) {
            TransferHelper.safeApprove(
                0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16,
                UNISWAP_ROUTER_ADDRESS,
                100000000000000000000
            );
        }
        uint256 id = poolinfo[0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]; 

        vars.balanceBefore = address(this).balance;

        vars._debt = userinvestment[vars.wallet][
            0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
        ].reward;
        vars._liqPrice = userinvestment[vars.wallet][
            0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16
        ].liqPrice;

        ///Withdraw from LP farm and rewards
        withdrawFarm(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16, vars.lptokens);

        ///Withdraw the liquidity
        (vars.tokenamount, vars.ETHamount) = dex.removeLiquidityETH(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,
            vars.lptokens,
            0,
            0,
            address(this),
            block.timestamp
        );

        (uint256 percentageUser, uint256 percentageLoan) = Operations.bnbtoBusd(
            oracle.getLatestPrice(id),
            vars.ETHamount,
            vars.tokenamount
        );

        vars._reward = Operations.cakeCalculation(
            MASTERCHEF_ADDRESS,
            3,
            vars.lptokens,
            vars._debt
        );

        uint256 useramount;
        if (vars._reward != 0) {
            (penalty, useramount) = liquidationDistribution(
                vars.wallet,
                vars._reward,
                percentageUser,
                percentageLoan
            );
        }

        (uint256 amountA, uint256 amountB) = Operations.orderAmount(
            vars.balanceBefore,
            vars.ETHamount
        );
        uint256 balance = amountA - amountB;

        vars.bnbamount = Operations.makeaSwapliquidation(
            address(dex),
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,
            balance
        );

        vault.deposit(vars.tokenamount);

        if (vars.bnbamount != 0) {
            vault.addReward(vars.bnbamount);
            vault.deposit(vars.bnbamount);
        }

        liquidation.deletePosition(_id);

        userinvestment[vars.wallet][0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]
            .lp = 0;

        userinvestment[vars.wallet][0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]
            .reward = 0;

        userinvestment[vars.wallet][0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]
            .farming = false;
        userinvestment[vars.wallet][0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]
            .liqPrice = 0;

        userinvestment[vars.wallet][0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16]
            .liqStatus = false;

        userdeposit[vars.wallet][_id].loan = 0;
        userdeposit[vars.wallet][_id].deposit = 0;
        openPositions[_id] = address(0);

        emit positionLiquidated(
            vars.wallet,
            _id,
            vars._liqPrice,
            useramount,
            penalty
        );
    }

    function liquidationDistribution(
        address _to,
        uint256 _rewards,
        uint256 percentageUser,
        uint256 percentageLoan
    ) internal returns (uint256 penalty, uint256 userrewards) {
        LiquidifierLocalVars memory vars;
        uint256 penaltyPrecentage = 500;

        uint _price = oracle.getLatestPrice(0);
        vars.busdvalue = _rewards * _price;

        vars.rewardUser = (vars.busdvalue * (percentageUser)) / 100000;

        vars.rewardLiquidifier = (vars.busdvalue * (percentageLoan)) / 100000;

        vault.addReward(vars.rewardLiquidifier);

        penalty = (vars.rewardUser * (penaltyPrecentage)) / 100000;

        vault.addReward(penalty);

        (uint256 amountA, uint256 amountB) = Operations.orderAmount(
            vars.rewardUser,
            penalty
        );

        userrewards = amountA - amountB;

        if (userrewards > 0) {
            vault.withdraw(userrewards);

            (vars.reward, ) = Operations.makeaSwapPanom(
                address(dex),
                0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,
                userrewards
            );
            //Transfer to the user
            TransferHelper.safeTransfer(
                0x5430A9E06E2dcc4Fc2760522057fb46128AE463f, //panoram token
                _to,
                vars.reward
            );
        }

        return (penalty, userrewards);
    }

    function updaterMasterChef(address _newchef) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        masterchef = IMasterChef(_newchef);
    }

    function updaterOracle(address _newOracle) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        oracle = IOracle(_newOracle);
    }

    function viewRewards(address _pool) public view returns (uint256 rewards) {
        uint256 id = poolinfo[_pool];
        return masterchef.pendingCake(id, address(this));
    }

    function emergencyExitPool(address _pool) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        uint256 id = poolinfo[_pool];
        masterchef.emergencyWithdraw(id);
    }

    function emergencyExitAllPools(address[] memory _pools) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        uint256 length = _pools.length;
        for (uint256 i = 0; i <= length; ) {
            uint256 id = poolinfo[_pools[i]];
            masterchef.emergencyWithdraw(id);
            unchecked {
                ++i;
            }
        }
    }

    function addPool(address _pool, uint256 _id) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        poolinfo[_pool] = _id;
        TransferHelper.safeApprove(
            _pool,
            address(masterchef),
            type(uint256).max //esto es el maximo en UINT256 o sustituir por 100000000000000000000
        ); //mainnet
    }

    function getUserDeposit(address _user, uint256 _id)
        public
        view
        returns (
            uint256 posId,
            uint256 _loan,
            uint256 _deposit,
            address token1,
            address token2
        )
    {
        posId = _id;
        _loan = userdeposit[_user][_id].loan;
        _deposit = userdeposit[_user][_id].deposit;
        token1 = userdeposit[_user][_id].firstToken;
        token2 = userdeposit[_user][_id].secondToken;

        return (posId, _loan, _deposit, token1, token2);
    }

    function getUserInvestment(address _user, address _lp)
        public
        view
        returns (
            uint256 lpamount,
            uint256 rewardamount,
            bool farmingState,
            uint256 liquidationAmount,
            bool liquidationState
        )
    {
        lpamount = userinvestment[_user][_lp].lp;
        rewardamount = userinvestment[_user][_lp].reward;
        farmingState = userinvestment[_user][_lp].farming;
        liquidationAmount = userinvestment[_user][_lp].liqPrice;
        liquidationState = userinvestment[_user][_lp].liqStatus;

        return (
            lpamount,
            rewardamount,
            farmingState,
            liquidationAmount,
            liquidationState
        );
    }

    fallback() external payable {
        /* deposit(); */
    }

    receive() external payable {
        /*   deposit(); */
    }

    ///@dev Use this functions only in test, delete when launching official product

    ///@notice Use this function to delete the contract at the end of the tests
    function kill() public {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert("have no admin role");
        }
        address payable addr = payable(address(msg.sender));
        selfdestruct(addr);
    }

    function changeLiqStatus(
        address _wallet,
        address _lp,
        bool status
    ) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        userinvestment[_wallet][_lp].liqStatus = status;
    }

    ///----------------------------------------------------------------
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

interface IUniswap {
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
            uint256,
            uint256,
            uint256
        );

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256, uint256);

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
    ) external returns (uint256, uint256);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;

    function poolInfo(uint256 _pid)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );

    function cakePerBlock(bool _isRegular) external view returns (uint256);

    function getBoostMultiplier(address _user, uint256 _pid)
        external
        view
        returns (uint256);

    function totalRegularAllocPoint() external view returns (uint256);

    function totalSpecialAllocPoint() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: MIT
pragma solidity >0.8.10;

interface IVault {
    function deposit(uint256) external;

    function addReward(uint256) external;

    function withdraw(uint256) external;

    function setStrategyContract(address) external;

    function setmultisig(address) external;

    function withdrawAll() external;

    function withdrawProfit(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IUniswap.sol";
import "./IMasterChef.sol";
import "./IPancakePair.sol";

abstract contract Operations is AccessControl, ReentrancyGuard {
    uint256 public constant BOOST_PRECISION = 100 * 1e10;

    function reserves(address _lp)
        internal
        view
        returns (uint256 reserve1, uint256 reserve2)
    {
        (reserve1, reserve2, ) = IPancakePair(_lp).getReserves();
    }

    function makePath(address tokenA, address tokenB)
        internal
        pure
        returns (address[] memory path)
    {
        path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
    }

    function orderAmount(uint256 amountA, uint256 amountB)
        internal
        pure
        returns (uint256 amount0, uint256 amount1)
    {
        (amount0, amount1) = amountA < amountB
            ? (amountB, amountA)
            : (amountA, amountB);
    }

    ///@notice This function calculates the reward that would have been generated so far by the user.
    function cakeCalculation(
        address _chef,
        uint256 idpool,
        uint256 lpamount,
        uint256 rewarddebt
    ) public view returns (uint256 _rewards) {
        (
            uint256 accCakePerShare,
            uint256 lastRewardBlock,
            uint256 allocPoint,
            uint256 totalBoostedShare,
            bool isRegular
        ) = IMasterChef(_chef).poolInfo(idpool);

        uint256 cakePerBlock = IMasterChef(_chef).cakePerBlock(true);

        if (block.number > lastRewardBlock && totalBoostedShare != 0) {
            uint256 multiplier = block.number - lastRewardBlock;

            uint256 cakeReward = ((multiplier * cakePerBlock) * allocPoint) /
                (
                    isRegular
                        ? IMasterChef(_chef).totalRegularAllocPoint()
                        : IMasterChef(_chef).totalSpecialAllocPoint()
                );

            accCakePerShare =
                accCakePerShare +
                ((cakeReward * 1e18) / totalBoostedShare);
        }
        uint256 boostedAmount = (lpamount *
            (IMasterChef(_chef).getBoostMultiplier(msg.sender, idpool))) /
            BOOST_PRECISION;

        _rewards = (boostedAmount * accCakePerShare) / 1e18 - rewarddebt;

        return _rewards;
    }

    ///@notice This function calculates the reward earned by the user.
    function rewardsRegistry(
        address _chef,
        uint256 lpamount,
        uint256 idpool
    ) internal view returns (uint256 reward) {
        uint256 multiplier = IMasterChef(_chef).getBoostMultiplier(
            msg.sender,
            idpool
        );
        (uint256 accCakePerShare, , , , ) = IMasterChef(_chef).poolInfo(idpool);

        return
            reward =
                (((lpamount * multiplier) / BOOST_PRECISION) *
                    accCakePerShare) /
                1e18;
    }

    ///@notice Calculates the amount of tokens based on the lp to be burned.
    ///@param lpamount Amount of lp to be burned
    function getAmountFromLp(address _lp, uint256 lpamount)
        public
        view
        returns (uint256 amount0, uint256 amount1)
    {
        address token0 = IPancakePair(_lp).token0(); //WBNB
        address token1 = IPancakePair(_lp).token1(); //BUSD
        uint256 balance0 = IERC20(token0).balanceOf(address(_lp));
        uint256 balance1 = IERC20(token1).balanceOf(address(_lp));
        uint256 _totalSupply = IPancakePair(_lp).totalSupply(); // Totalsupply del contrato de LP
        amount0 = (lpamount * balance0) / _totalSupply;
        amount1 = (lpamount * balance1) / _totalSupply;
        return (amount0, amount1);
    }

    function makeaSwapCake(
        address dex,
        address cake,
        address busd
    ) internal returns (uint256 _amount, uint256 cakeAmount) {
        cakeAmount = IERC20(cake).balanceOf(address(this));
        if (cakeAmount != 0) {
            address[] memory path = Operations.makePath(cake, busd);
            uint256[] memory swap = IUniswap(dex).swapExactTokensForTokens(
                cakeAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            _amount = swap[1];

            return (_amount, cakeAmount);
        }
    }

    function makeaSwapPanom(
        address dex,
        address busd,
        uint256 busdAmount
    ) internal returns (uint256 amount, uint256 _busdAmount) {
        if (busdAmount != 0) {
            address[] memory path = Operations.makePath(
                busd,
                0x5430A9E06E2dcc4Fc2760522057fb46128AE463f //Tenesse token
            );

            uint256[] memory swap = IUniswap(dex).swapExactTokensForTokens(
                busdAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            amount = swap[1];

            return (amount, busdAmount);
        }
    }

    function makeaSwapliquidation(
        address dex,
        address busd,
        uint256 bnbAmount
    ) internal returns (uint256 busdAmount) {
        if (bnbAmount != 0) {
            address[] memory path = Operations.makePath(
                0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c, //WBNB address
                busd
            );
            uint256[] memory amounts = IUniswap(dex).swapExactETHForTokens{
                value: bnbAmount
            }(0, path, address(this), block.timestamp);

            busdAmount = amounts[1];
        }

        return busdAmount;
    }

    function bnbtoBusd(
        uint _price,
        uint256 _ethAmount,
        uint256 amountToken
    ) internal pure returns (uint256 percentageUser, uint256 percentageLoan) {
       
        uint256 _amount = _ethAmount * _price;

        uint256 totalvalue = _amount + amountToken;

        //Calculation of the corresponding percentage of rewards
        percentageUser = (_amount * 100000) / totalvalue;
        //uint256 percentage1 = (_amount * 100) / totalvalue;

        percentageLoan = (amountToken * 100000) / totalvalue;
        //uint256 percentage2 = (amountToken * 100) / totalvalue;

        return (percentageUser, percentageLoan);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IOracle {
    function getLatestPrice(uint256) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ILiquidation {
    function liquidationPrice(uint256, uint256) external view returns (uint256);

    function liquidationState(uint256, uint256) external view returns (bool);

    function addPosition(uint256) external;

    function deletePosition(uint256) external;

    function setStrategyContract(address) external;

    function verifyMerkle(
        bytes32[] memory,
        bytes32,
        uint256
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}