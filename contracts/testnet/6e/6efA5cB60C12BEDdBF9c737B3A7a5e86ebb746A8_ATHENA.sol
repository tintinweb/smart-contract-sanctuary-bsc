// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
}

contract ATHENA {
    string public name = "ATHENA";
    string public symbol = "ATH";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public lpStaking;
    address private burnAddress = 0x000000000000000000000000000000000000dEaD; //燃烧地址
    address public routerAddress = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0; //uniswapRouter
    address public usdtAddress = 0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; //usdtAddress
    address public lpPairAddress; //lpPairAddress
    bool public swapTokenToMarketEnabled = true;
    uint256 public swapTokenOverflowNum = 30 * 10**decimals; //超过多少个token可以转换成市场 500

    uint256 public buyFee = 30; // 30/1000
    uint256 public buyInviteFee = 10; // 10/1000
    uint256 public burnFee = 10; // 10/1000
    uint256 public operateFee = 10; // 10/1000
    address public operateAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; //1%运营

    uint256 public sellFee = 60; // 60/1000
    uint256 public sellInviteFee = 10; // 10/1000
    uint256 public lpFee = 20; // 20/1000
    uint256 public marketFee = 30; // 10/1000 //奖励市场钱包，分红触发卖成USDT

    mapping(address => bool) public whitelist; // 白名单
    mapping(address => bool) public blacklist; // 黑名单
    mapping(address => bool) public pairlist; // 流动池

    mapping(address => address) public inviter; // 邀请人
    mapping(address => uint256) public inviteCount; // 邀请人数量

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed holder,
        address indexed spender,
        uint256 value
    );
    event BindInviter(address indexed _user, address indexed _inviter);

    constructor(address dao_, address _lp_staking) {
        owner = msg.sender;
        lpStaking = _lp_staking;

        whitelist[owner] = true;
        whitelist[dao_] = true;
        whitelist[lpStaking] = true;
        whitelist[address(this)] = true;

        uint256 _totalSupply = 10000000 * 10**decimals;
        uint256 lpSupply = 3360000 * 10**decimals;
        _mint(dao_, _totalSupply - lpSupply);
        _mint(lpStaking, lpSupply);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        lpPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);
        pairlist[lpPairAddress] = true;

        allowance[address(this)][routerAddress] = ~uint256(0);
        safeApprove(usdtAddress, lpStaking, ~uint256(0));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function setOperateAddress(address _operateAddress) public onlyOwner {
        operateAddress = _operateAddress;
    }

    function setLpStaking(address _lp_staking) public onlyOwner {
        lpStaking = _lp_staking;
    }

    function setBurnAddress(address _burnAddress) public onlyOwner {
        burnAddress = _burnAddress;
    }

    function setLpPairAddress(address _lpPairAddress) public onlyOwner {
        lpPairAddress = _lpPairAddress;
    }

    function setUsdtAddress(address _usdtAddress) public onlyOwner {
        usdtAddress = _usdtAddress;
    }

    function setSwapTokenToMarketEnabled(bool _swapTokenToMarketEnabled)
        public
        onlyOwner
    {
        swapTokenToMarketEnabled = _swapTokenToMarketEnabled;
    }

    function setSwapTokenOverflowNum(uint256 _swapTokenOverflowNum)
        public
        onlyOwner
    {
        swapTokenOverflowNum = _swapTokenOverflowNum;
    }

    function setBuyFee(
        uint256 _inviteFee,
        uint256 _burnFee,
        uint256 _operateFee
    ) public onlyOwner {
        buyFee = _inviteFee + _burnFee + _operateFee;
        buyInviteFee = _inviteFee;
        burnFee = _burnFee;
        operateFee = _operateFee;
    }

    function setSellFee(
        uint256 _inviteFee,
        uint256 _lpFee,
        uint256 _marketFee
    ) public onlyOwner {
        sellFee = _inviteFee + _lpFee + _marketFee;
        sellInviteFee = _inviteFee;
        lpFee = _lpFee;
        marketFee = _marketFee;
    }

    function setWhitelist(address addr, bool value) public onlyOwner {
        whitelist[addr] = value;
    }

    function setBlacklist(address addr, bool value) public onlyOwner {
        blacklist[addr] = value;
    }

    function setPairlist(address addr, bool value) public onlyOwner {
        pairlist[addr] = value;
    }

    // 绑定邀请人
    function setInviter(address inviter_) external virtual returns (bool) {
        require(inviter[msg.sender] == address(0), "has been invited");
        require(msg.sender != inviter_, "don't invite yourself");

        require(inviter[inviter_] != msg.sender, "inviter invited error");

        inviter[msg.sender] = inviter_;
        inviteCount[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!blacklist[sender], "ERC20: transfer from blacklisted account");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balanceOf[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            balanceOf[sender] = senderBalance - amount;
        }
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address holder,
        address spender,
        uint256 amount
    ) internal virtual {
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (amount == 0 || whitelist[to] || whitelist[from]) {
            return;
        }
        if (pairlist[from] && buyFee > 0) {
            takeFee(to, burnAddress, amount, burnFee);
            takeFee(to, operateAddress, amount, operateFee);

            address _invite = inviter[to];
            if (_invite != address(0)) {
                takeFee(to, _invite, amount, buyInviteFee);
            } else {
                takeFee(to, operateAddress, amount, buyInviteFee);
            }
        } else if (pairlist[to] && sellFee > 0) {
            takeFee(to, lpPairAddress, amount, lpFee);
            address _invite = inviter[from];
            if (_invite != address(0)) {
                takeFee(to, _invite, amount, sellInviteFee);
            } else {
                takeFee(to, operateAddress, amount, sellInviteFee);
            }

            takeFee(to, address(this), amount, marketFee);
        } else {
            swapTokensForToken();
        }
    }

    function takeFee(
        address _spender,
        address _to,
        uint256 amount,
        uint256 _feeRate
    ) private {
        if (_feeRate > 0) {
            uint256 _fee = (amount * _feeRate) / 1000;
            balanceOf[_to] += _fee;
            balanceOf[_spender] -= _fee;
            emit Transfer(_spender, _to, _fee);
        }
    }

    function swapTokensForToken() public {
        uint256 tokenAmount = balanceOf[address(this)];
        if (swapTokenToMarketEnabled && tokenAmount > swapTokenOverflowNum) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtAddress;

            IUniswapV2Router02(routerAddress)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0, // accept any amount of ETH
                    path,
                    address(this),
                    block.timestamp
                );
        }
    }

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
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function approveUinswap() public onlyOwner {
        allowance[address(this)][routerAddress] = ~uint256(0);
    }

    function approveToken(address token, address to) public onlyOwner {
        safeApprove(token, to, ~uint256(0));
    }
}