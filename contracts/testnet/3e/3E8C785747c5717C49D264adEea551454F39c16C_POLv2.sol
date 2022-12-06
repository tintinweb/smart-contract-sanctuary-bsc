/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: IDistributor

interface IDistributor {
    function BUSD() external returns (address);

    function distributeFunds(
        uint256 amount,
        uint256 treasury,
        uint256 pricefloor,
        uint256 team
    ) external;
}

// Part: IFoundation

interface IFoundation {
    function distribute(uint256 amount) external;
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address owner, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

// Part: IPOL

interface IPOL is IToken {
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 base_amount
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 min_base,
        uint256 min_tokens
    ) external returns (uint256, uint256);

    function swap(
        uint256 base_input,
        uint256 token_input,
        uint256 base_output,
        uint256 token_output,
        uint256 min_intout,
        address _to
    ) external returns (uint256 _output);

    function getBaseToLiquidityInputPrice(uint256 base_amount)
        external
        view
        returns (uint256 liquidity_minted, uint256 token_amount_needed);

    function outputTokens(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function outputBase(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function addLiquidityFromBase(uint256 _base_amount)
        external
        returns (uint256);

    function removeLiquidityToBase(uint256 _liquidity, uint256 _tax)
        external
        returns (uint256 _base);
}

// File: POL.sol

// The POL is basically an LP pair token that will both charge taxes and distribute them
// as well as control swaps. This iteration will use BUSD as the pair token. POL is paired with the
// Foundation, as it will send rewards to stakers in it in LP tokens.
// In order for the pair to be used in DEX's we'll try to keep the implementation as close to UNISWAP LP as possible
contract POLv2 is IPOL {
    struct Sells {
        uint256 amountSold;
        uint256 lastSell;
    }
    address public owner;

    IToken public token;
    IToken public base;
    uint256 public constant BASE = 100;
    // These taxes are divided 100
    uint256 public buyTax = 13;
    uint256 public sellTax = 18;
    // 0 - Stake Buy back and burn
    // 1 - Foundation BUSD rewards
    // 2 - Stoke lock
    // 3 - Treasury Distribution
    // 4, 5, 6 -> Distribution ratios (treasury, price floor protection, team)
    // Changing these will update the total tax amount on BUYTAX AND SELLTAX respectively
    uint256[7] public buyTaxes = [5, 4, 1, 3, 5, 3, 3];
    uint256[7] public sellTaxes = [5, 4, 1, 8, 5, 3, 3];

    // MAX daily sells
    uint256 public maxDailySell = 500 ether;
    // ------------------------------------------------
    //           Ecosystem addresses
    // ------------------------------------------------
    address public foundation;
    address public fundsDistributor;
    address public _lock;
    // ------------------------------------------------
    //               Whitelist
    // ------------------------------------------------
    mapping(address => bool) public whitelist; // TAXES
    mapping(address => bool) public noSellLimit; // SELL LIMIT
    // ------------------------------------------------
    //               ERC20 Specific
    // ------------------------------------------------
    string private constant _name = "Stake LP V2";
    string private constant _symbol = "STOKE";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => Sells) public sellTracker;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    // ------------------------------------------------
    // ------------------------------------------------

    // ------------------------------------------------
    //              LIQUIDITY EVENTS
    // ------------------------------------------------

    event onAddLiquidity(
        address indexed provider,
        uint256 _liquidity_amount,
        uint256 base_amount,
        uint256 token_amount
    );
    event onRemoveLiquidity(
        address indexed provider,
        uint256 _liquidity_amount,
        uint256 base_amount,
        uint256 token_amount
    );
    event Swap(
        address indexed _user,
        uint256 _baseInput,
        uint256 _tokenInput,
        uint256 _baseOutput,
        uint256 _tokenOutput
    );

    // ------------------------------------------------
    // ------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender], "Not Whitelist");
        _;
    }

    constructor(address _token, address _base) {
        owner = msg.sender;
        token = IToken(_token);
        base = IToken(_base);
    }

    // ------------------------------------------------
    //                  ERC20 FUNCTIONS
    // ------------------------------------------------
    function balanceOf(address from) public view returns (uint256) {
        return _balances[from];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function burnFrom(address _owner, uint256 amount) public {
        require(
            _allowances[_owner][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[_owner][msg.sender] -= amount;
        _burn(_owner, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(
            _allowances[from][msg.sender] >= amount,
            "Insufficient Allowance"
        );
        _allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0) && from != address(0), "Zero"); // Cant transfer to/from zero address
        _balances[from] -= amount; // uint underflow prevents spending more than the user has
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _burn(address from, uint256 amount) private {
        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function _mint(address to, uint256 amount) private {
        _balances[to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function mint(address to, uint256 amount) external {
        // DO NOTHING mint will only be internal here
    }

    // ------------------------------------------------
    // ------------------------------------------------

    /// @notice Remember to set this contract as excluded from taxes. since transferring tokens burns tokens
    /**
     * @notice Deposit BNB && Tokens (STAKE) at current ratio to mint STOKE tokens.
     * @dev min_liquidity does nothing when total SWAP supply is 0.
     * @param min_liquidity Minimum number of STOKE sender will mint if total STAKE supply is greater than 0.
     * @param max_tokens Maximum number of tokens deposited. Deposits max amount if total STOKE supply is 0.
     * @return The amount of SWAP minted.
     */
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 base_amount
    ) public returns (uint256) {
        require(max_tokens > 0 && base_amount > 0, "ALIQ1"); //dev: Invalid Arguments
        require(
            base.transferFrom(msg.sender, address(this), base_amount),
            "ALIQ2"
        ); // dev: Can't transfer tokens
        require(min_liquidity > 0, "ALIQ3"); //dev: Minimum liquidity to add must be greater than zero

        uint256 tokenAmount;
        uint256 totalLiq = totalSupply();
        if (totalLiq > 0) {
            uint256 base_reserve = base.balanceOf(address(this)) - base_amount;
            uint256 token_reserve = token.balanceOf(address(this));
            tokenAmount = ((base_amount * token_reserve) / base_reserve) + 1;
            uint256 liqToMint = (base_amount * totalLiq) / base_reserve;
            require(
                max_tokens >= tokenAmount && liqToMint >= min_liquidity,
                "ALIQ4"
            ); //dev: Token amounts mismatch
            require(
                token.transferFrom(msg.sender, address(this), tokenAmount),
                "ALIQ5"
            ); // dev: transfer of TOKEN unsuccessful
            _mint(msg.sender, liqToMint);
            emit onAddLiquidity(
                msg.sender,
                liqToMint,
                base_amount,
                tokenAmount
            );
            return liqToMint;
        }

        require(base_amount >= 1 ether, "ALIQ6"); // dev: invalid initial amount of liquidity created
        tokenAmount = max_tokens;
        uint256 initLiq = base.balanceOf(address(this));
        _mint(msg.sender, initLiq);
        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "ALIQ7"
        ); // dev: unsuccessful transfer from on init liquidity
        emit onAddLiquidity(msg.sender, initLiq, base_amount, tokenAmount);
        return initLiq;
    }

    function addLiquidityFromBase(uint256 _base)
        public
        onlyWhitelist
        returns (uint256 _liquidity)
    {
        uint256 resBase = baseReserve();
        uint256 resToken = tokenReserve();

        base.transferFrom(msg.sender, address(this), _base);
        // technically we don't need to do anything with the tokens but def, only whitelisted users/contracts can/should do it this way
        uint256 base_swap = _base / 2;
        uint256 base_remain = _base - base_swap;
        uint256 tokens = (base_swap * resToken) / (resBase + base_swap);
        // Tax occurs here
        // We keep the stake burn and treasury tax
        uint256 toBurn = (tokens * buyTaxes[0]) / BASE;
        token.burn(toBurn);
        uint256 toTreasury = (base_swap * buyTaxes[3]) / BASE;
        base.approve(fundsDistributor, toTreasury);
        IDistributor(fundsDistributor).distributeFunds(
            toTreasury,
            buyTaxes[4],
            buyTaxes[5],
            buyTaxes[6]
        );

        base_swap -= toTreasury;
        _liquidity = (base_remain * totalSupply()) / (resBase + base_swap);

        tokens = (base_remain * resToken) / (resBase + base_swap);

        _mint(msg.sender, _liquidity);
        emit onAddLiquidity(msg.sender, _liquidity, base_swap, tokens);
    }

    function removeLiquidityToBase(uint256 _liquidity, uint256 _tax)
        public
        onlyWhitelist
        returns (uint256 _base)
    {
        uint256 resBase = baseReserve();
        uint256 resToken = tokenReserve();
        uint256 total = totalSupply();
        uint256 tokens = (_liquidity * resToken) / total;
        _base = (_liquidity * resBase) / total;
        emit onRemoveLiquidity(msg.sender, _liquidity, _base, tokens);
        // burn stake tax
        uint256 tax = (_tax * resToken) / total;
        token.burn(tax);
        // Distribute Treasury sell tax This is only half of the tax percent
        tax = (_base * _tax) / _liquidity;
        base.approve(fundsDistributor, tax);
        IDistributor(fundsDistributor).distributeFunds(
            tax,
            sellTaxes[4],
            sellTaxes[5],
            sellTaxes[6]
        );
        //both base and tax are x2 since the tax in BUSD is only half of the total tax
        _base = (_base - _tax) * 2;
        // Burn _liquidity from msg.sender;
        burn(_liquidity);
        base.transfer(msg.sender, _base);
    }

    /**
     * @dev Burn SWAP tokens to withdraw BNB && Tokens at current ratio.
     * @param amount Amount of SWAP burned.
     * @param min_base Minimum BASE TOKEN withdrawn.
     * @param min_tokens Minimum Tokens withdrawn.
     * @return The amount of BASE && Tokens withdrawn.
     */
    function removeLiquidity(
        uint256 amount,
        uint256 min_base,
        uint256 min_tokens
    ) public returns (uint256, uint256) {
        require(amount > 0 && min_base > 0 && min_tokens > 0);
        uint256 total_liquidity = totalSupply();
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 base_amount = (amount * base.balanceOf(address(this))) /
            total_liquidity;
        uint256 token_amount = (amount * (token_reserve)) / total_liquidity;
        require(base_amount >= min_base && token_amount >= min_tokens, "RLIQ1"); // Not enough tokens to receive
        _burn(msg.sender, amount);
        require(base.transfer(msg.sender, base_amount), "RLIQ2"); // dev: Error transfering base tokens
        require(token.transfer(msg.sender, token_amount), "RLIQ3"); //dev: Error transferring other tokens
        emit onRemoveLiquidity(msg.sender, amount, base_amount, token_amount);
        return (base_amount, token_amount);
    }

    ///@notice swap from one token to the other, please make sure only one value is inputted, as the rest will be ignored
    /// @param base_input amount of BASE tokens to input for swap
    /// @param token_input amount of TOKENS to input for swap
    /// @param base_output amount of BASE tokens to receive
    /// @param token_output amount of TOKENs to receive
    /// @param min_intout minimum amount so swap is considered successful
    /// @param _to receiver of the swapped tokens
    /// @return _output amount of tokens to receive
    function swap(
        uint256 base_input,
        uint256 token_input,
        uint256 base_output,
        uint256 token_output,
        uint256 min_intout,
        address _to
    ) public returns (uint256 _output) {
        uint256 tokenRes = tokenReserve();
        uint256 baseRes = baseReserve();
        // BUYER IS ALWAYS MSG.SENDER
        if (base_input > 0)
            _output = baseToToken(
                base_input,
                min_intout,
                _to,
                msg.sender,
                baseRes,
                tokenRes
            );
        else if (token_output > 0)
            _output = baseToToken(
                min_intout,
                token_output,
                _to,
                msg.sender,
                baseRes,
                tokenRes
            );
            // TODO CHECK THE NEXT 2
        else if (token_input > 0)
            _output = tokenToBase(
                token_input,
                min_intout,
                _to,
                msg.sender,
                baseRes,
                tokenRes
            );
        else if (base_output > 0)
            _output = tokenToBase(
                min_intout,
                base_output,
                _to,
                msg.sender,
                baseRes,
                tokenRes
            );
    }

    function baseToToken(
        uint256 _base,
        uint256 _min,
        address _to,
        address _buyer,
        uint256 resBase,
        uint256 resToken
    ) private returns (uint256 out) {
        // Transfer BUSD here for usage
        base.transferFrom(_buyer, address(this), _base);
        out = getInputPrice(_base, resBase, resToken);
        if (whitelist[_buyer]) {
            require(out >= _min, "BT1"); // dev: Base definitely not enough
            // Transfer final amount to recipient
            token.transfer(_to, out);
            emit Swap(msg.sender, _base, 0, 0, out);
            return out;
        }
        uint256 tax_1 = (_base * buyTaxes[2]) / BASE / 2;
        (uint256 tax_2, uint256 tax_3) = getLiquidityInputPrice(
            tax_1,
            resBase,
            resToken,
            totalSupply()
        );
        //    Mint Liquidity
        emit onAddLiquidity(_lock, tax_2, tax_1, tax_3);
        _mint(_lock, tax_2);
        // Foundation Tax
        tax_2 = (_base * buyTaxes[1]) / BASE;
        tax_1 += tax_2;
        base.approve(foundation, tax_2);
        IFoundation(foundation).distribute(tax_2);
        // Treasury Distribution
        tax_2 = (_base * buyTaxes[3]) / BASE;
        tax_1 += tax_2;
        base.approve(fundsDistributor, tax_2);
        IDistributor(fundsDistributor).distributeFunds(
            tax_2,
            buyTaxes[4],
            buyTaxes[5],
            buyTaxes[6]
        );
        // BURN TOKEN
        tax_2 = (out * buyTaxes[0]) / BASE;
        token.burn(tax_2);

        // TAX_1 is the proportional amount used in TOKENS
        tax_1 = (out * (buyTaxes[1] + buyTaxes[2] + buyTaxes[3])) / BASE;
        //  Remove TAXES from OUTPUT
        out -= tax_1 + tax_2;
        require(out >= _min, "BT1_"); // dev: minimum
        token.transfer(_to, out);
        emit Swap(msg.sender, _base, 0, 0, out);
    }

    function tokenToBase(
        uint256 _token,
        uint256 _min,
        address _to,
        address _buyer,
        uint256 resBase,
        uint256 resToken
    ) private returns (uint256 out) {
        // Transfer in Token
        token.transferFrom(_buyer, address(this), _token);
        out = getInputPrice(_token, resToken, resBase);
        if (whitelist[_buyer]) {
            require(out >= _min, "TB1"); // dev: Base definitely not enough
            // Transfer final amount to recipient
            base.transfer(_to, out);
            emit Swap(_buyer, 0, _token, out, 0);
            return out;
        }
        if (!noSellLimit[_buyer]) {
            bool prev24hours = block.timestamp - sellTracker[_buyer].lastSell <
                24 hours;

            if (prev24hours) {
                require(
                    sellTracker[_buyer].amountSold + _token <= maxDailySell,
                    "MXSELL"
                );
                sellTracker[_buyer].amountSold += _token;
            } else {
                require(_token <= maxDailySell, "MXSELL2");
                sellTracker[_buyer].lastSell = block.timestamp;
                sellTracker[_buyer].amountSold = _token;
            }
        }
        // BURN 5%
        uint256 tax_1 = (_token * sellTaxes[0]) / BASE;
        token.burn(tax_1);
        // Amount of TOKEN used for Liquidity
        tax_1 = (_token * sellTaxes[2]) / BASE / 2;

        (uint256 tax_2, uint256 tax_3) = getLiquidityInputPrice(
            tax_1,
            resToken,
            resBase,
            totalSupply()
        );
        emit onAddLiquidity(_lock, tax_2, tax_1, tax_3);
        _mint(_lock, tax_2);
        // foundation
        tax_1 = (out * sellTaxes[1]) / BASE;
        base.approve(foundation, tax_1);
        IFoundation(foundation).distribute(tax_1);
        // funds Distributor
        tax_2 = (out * sellTaxes[3]) / BASE;
        base.approve(fundsDistributor, tax_2);
        IDistributor(fundsDistributor).distributeFunds(
            tax_2,
            sellTaxes[4],
            sellTaxes[5],
            sellTaxes[6]
        );

        tax_1 += tax_2;
        tax_2 = (out * (sellTaxes[0] + sellTaxes[2])) / BASE;
        out -= tax_1 + tax_2;

        require(out >= _min, "TB2"); // dev: less than minimum
        base.transfer(_to, out);
        emit Swap(_buyer, 0, _token, out, 0);
    }

    function tokenReserve() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function baseReserve() public view returns (uint256) {
        return base.balanceOf(address(this));
    }

    /**
     * @dev Pricing function for converting between BNB && Tokens without fee when we get the input variable.
     * @param input_amount Amount token or base being sold.
     * @param input_reserve Amount of input token type in exchange reserves.
     * @param output_reserve Amount of output token type in exchange reserves.
     * @return Amount of Output tokens to receive.
     */
    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) public pure returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0, "INVALID_VALUE");
        uint256 numerator = input_amount * output_reserve;
        uint256 denominator = input_reserve + input_amount;
        return numerator / denominator;
    }

    /**
     * @dev Pricing function for converting between BNB && Tokens without fee when we get the output variable.
     * @param output_amount Amount of output token type being bought.
     * @param input_reserve Amount of input token type in exchange reserves.
     * @param output_reserve Amount of output token type in exchange reserves.
     * @return Amount of input token to receive.
     */
    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) public pure returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0);
        uint256 numerator = input_reserve * output_amount;
        uint256 denominator = (output_reserve - output_amount);
        return (numerator / denominator) + 1;
    }

    /**
     * @dev Pricing function for tokens, depending on the isDesired flag we either get the Input Base needed or the output amount
     * @param _amount the amount of tokens that will be sent for swap
     * @param isDesired FLAG - this tells us wether we want the BASE amount needed or the TOKENs that will be output
     */
    function outputTokens(uint256 _amount, bool isDesired)
        public
        view
        returns (uint256)
    {
        if (isDesired)
            return
                getOutputPrice(
                    _amount,
                    base.balanceOf(address(this)),
                    token.balanceOf(address(this))
                );
        return
            getInputPrice(
                _amount,
                base.balanceOf(address(this)),
                token.balanceOf(address(this))
            );
    }

    /// @notice same as outputTokens function except it is based on getting back BASE and inputting TOKEN
    function outputBase(uint256 _amount, bool isDesired)
        public
        view
        returns (uint256)
    {
        if (isDesired)
            return
                getOutputPrice(
                    _amount,
                    token.balanceOf(address(this)),
                    base.balanceOf(address(this))
                );
        return
            getInputPrice(
                _amount,
                token.balanceOf(address(this)),
                base.balanceOf(address(this))
            );
    }

    /// @notice get the amount of liquidity that would be minted and tokens needed by inputing the _base_amount
    /// @param _base_amount Amount of BASE tokens to use
    function getBaseToLiquidityInputPrice(uint256 _base_amount)
        external
        view
        returns (uint256 liquidity_amount, uint256 token_amount)
    {
        if (_base_amount == 0) return (0, 0);
        token_amount = 0;
        uint256 total = totalSupply();
        uint256 base_reserve = base.balanceOf(address(this));
        uint256 token_reserve = token.balanceOf(address(this));
        // +1 is to offset any decimal issues
        (liquidity_amount, token_amount) = getLiquidityInputPrice(
            _base_amount,
            base_reserve,
            token_reserve,
            total
        );
    }

    /// @notice get the amount of liquidity that would be minted and tokens needed by inputing the _base_amount
    /// @param _token_amount Amount of BASE tokens to use
    function getTokenToLiquidityInputPrice(uint256 _token_amount)
        external
        view
        returns (uint256 liquidity_amount, uint256 base_amount)
    {
        if (_token_amount == 0) return (0, 0);
        base_amount = 0;
        uint256 total = totalSupply();
        uint256 base_reserve = base.balanceOf(address(this));
        uint256 token_reserve = token.balanceOf(address(this));
        // +1 is to offset any decimal issues
        (liquidity_amount, base_amount) = getLiquidityInputPrice(
            _token_amount,
            token_reserve,
            base_reserve,
            total
        );
    }

    function getLiquidityInputPrice(
        uint256 input,
        uint256 inputReserve,
        uint256 otherReserve,
        uint256 currentLiqSupply
    ) internal pure returns (uint256 liquity_gen, uint256 tokens_needed) {
        liquity_gen = (input * currentLiqSupply) / inputReserve;
        tokens_needed = ((input * otherReserve) / inputReserve) + 1;
    }

    function setFundDistributor(address _newFund) external onlyOwner {
        require(IDistributor(_newFund).BUSD() == address(base), "FDX"); // dev: Invalid Fund distributor contract
        fundsDistributor = _newFund;
    }

    function setFoundation(address _newFoundation) external onlyOwner {
        require(_newFoundation != address(0), "FDTX"); // dev: Invalid Foundation contract
        foundation = _newFoundation;
    }

    function setLiquidityLock(address _newLock) external onlyOwner {
        require(_newLock != address(0), "FDTX"); // dev: Invalid Foundation contract
        _lock = _newLock;
    }

    function setWhitelistStatus(address _user, bool _status)
        external
        onlyOwner
    {
        whitelist[_user] = _status;
    }

    function setSellLimitStatus(address _user, bool _status)
        external
        onlyOwner
    {
        noSellLimit[_user] = _status;
    }

    function setTaxes(bool isBuy, uint256[7] calldata taxDistribution)
        external
        onlyOwner
    {
        uint256 totalTax = taxDistribution[0] +
            taxDistribution[1] +
            taxDistribution[2] +
            taxDistribution[3];
        require(totalTax <= 35, "TX1"); // Max taxes reached
        if (isBuy) {
            buyTaxes = taxDistribution;
            buyTax = totalTax;
            return;
        }
        sellTaxes = taxDistribution;
        sellTax = totalTax;
        return;
    }

    function editMaxSell(uint256 _newMax) external onlyOwner {
        maxDailySell = _newMax;
    }
}