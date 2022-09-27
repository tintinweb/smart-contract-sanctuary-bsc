// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IPancakeRouter02.sol";

contract ACMClaim is Ownable {

    struct Funds {
        uint ts; // 时间戳
        uint uAmount; // u数量
        uint tokenAmount; // 代币数量
        address tokenContract; // 合约地址
        uint lpAmount; // lp数量
        bool claimed; // 是否领取
        uint pidx; // 仓位
        uint eidx; // 期下标
        uint epochNum; // 期数
        uint participatedAmount; // 认购数量
        uint fundType; // 类型 1筹满 ｜ 2爆仓 ｜ 3结束 ｜ 4重组
    }

    // 当期筹满时每个地址可领取资金
    mapping (bytes32 => Funds) private currentFunds;
    // 当期爆仓清算金额
    mapping (bytes32 => Funds) private liquidationCurrentFunds;
    // 第五期完成时每个地址可领取资金
    mapping (bytes32 => Funds) private completeFunds;
    // 重组资金
    mapping (bytes32 => Funds) private reorganizationFunds;
    
    // 记录各个地址参加信息
    mapping (address => mapping (uint => Funds)) searchFroFunds;
    // U代币
    address public USD;
    // TCD代币
    address public TCD;
    // ACM 代币
    address public ACM;
    // 销毁地址
    // address public destory = 0x000000000000000000000000000000000000dEaD;
    address public destory = 0xa4A0cD398b2092E516a4695096419635b1E0a003;
    // 管理员地址
    address public devAddress;
    uint public remainingACMSupply = 1540000000000000000000000;
    // 合约地址到交易路由的映射
    mapping (address => bool) private suppotredTokenMap;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] private supportedTokenContract;
    address public IDO;
    modifier onlyIDO() {
        require(msg.sender == IDO, "ACMClaim: caller is not the IDO");
        _;
    }

    constructor(address U, address T, address A, address dev) {
        USD = U;
        TCD = T;
        ACM = A;
        devAddress = dev;
    }

    // 领取当期筹满资金
    function receiveCurrentFunds(bytes32 h, address to) public onlyIDO {
        Funds storage currentFund = currentFunds[h];
        require (!currentFund.claimed && currentFund.uAmount > 0, "No quantity available");
        uint uAmount = currentFund.uAmount;
        uint tokenAmount = currentFund.tokenAmount;
        currentFund.claimed = true;
        // 只有代币为ACM才会销毁，否则不销毁
        if ( tokenAmount > 0 && currentFund.tokenContract == ACM) {
            IERC20(ACM).transfer(destory, tokenAmount);
        }

        // 返还U
        if (uAmount > 0) {
            IERC20(USD).transfer(to, uAmount);
        }
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(bytes32 h, address to) public onlyIDO {
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        require (!liquidationCurrentFund.claimed && liquidationCurrentFund.uAmount > 0, "No quantity available");
        uint uAmount = liquidationCurrentFund.uAmount;
        uint tokenAmount = liquidationCurrentFund.tokenAmount;
        liquidationCurrentFund.claimed = true;
        IERC20 token = IERC20(liquidationCurrentFund.tokenContract);
        // 返还代币和U ACM总量145万，ACM总量没反完之前会一直反双倍，否则没有双倍
        if (tokenAmount > 0) {
            if (liquidationCurrentFund.tokenContract == ACM && remainingACMSupply >= tokenAmount * 2) {
                remainingACMSupply -= tokenAmount;
                IERC20(ACM).transfer(to, tokenAmount * 2);
            } else{
                token.transfer(to, tokenAmount);
            }
        }
        if (uAmount > 0) {
            IERC20(USD).transfer(to, uAmount);
        }
    }

    // 领取第五期筹满或爆仓资金
    function receiveCompleteFunds(bytes32 h, address to) public onlyIDO {
        Funds storage completeFund = completeFunds[h];
        require (!completeFund.claimed && completeFund.uAmount > 0, "No quantity available");
        uint uAmount = completeFund.uAmount;
        uint lpAmount = completeFund.lpAmount;
        completeFund.claimed = true;
        // 组LP
        if (lpAmount > 0) {
            _swapAndLiquify(lpAmount, devAddress);
        }
        // 返U
        if (uAmount > 0) {
            IERC20(USD).transfer(to, uAmount);
        }
    }

    // 领取爆仓的LP
    function receiveLiquidationFunds(bytes32 h, address to, uint subStageAmount, uint totalAmount) public onlyIDO {
        require (!reorganizationFunds[h].claimed && reorganizationFunds[h].participatedAmount > 0, "No quantity available");
        // 能组LP的额度
        uint lpAmount = subStageAmount * reorganizationFunds[h].participatedAmount / totalAmount;
        // 组LP
        _swapAndLiquify(lpAmount, to);
    } 

    // 交换代币同时增加流动性
    function _swapAndLiquify(uint256 amount, address to) private {
        uint256 half = amount / 2;
        uint256 otherHalf = amount - half;
        uint256 initialBalance = IERC20(TCD).balanceOf(address(this));

        // swap tokens for BNB
        _swapUForToken(half);

        // how much BNB did we just swap into?
        uint256 newBalance = IERC20(TCD).balanceOf(address(this)) - initialBalance;

        // add liquidity to uniswap
        _addLiquidity(otherHalf, newBalance, to);
    }

    // swap代币
    function _swapUForToken(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = USD;
        path[1] = TCD;

        IERC20(USD).approve(router, tokenAmount);

        // make the swap
        IPancakeRouter02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    // 增加流动性
    function _addLiquidity(uint256 tokenAmount, uint256 uAmount, address to) private {
        // approve token transfer to cover all possible scenarios
        IPancakeRouter02 r = IPancakeRouter02(router);
        IERC20(TCD).approve(router, tokenAmount);
        IERC20(USD).approve(router, uAmount);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        r.addLiquidity(
            TCD,
            USD,
            tokenAmount,
            uAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            to,
            block.timestamp
        );
    }

    function setCurrentFund(bytes32 h, uint participatedAmount, uint uAmount, uint tokenAmount, address tokenContract, uint pidx, uint eidx, uint epochNum) public onlyIDO {
        Funds storage currentFund = currentFunds[h];
        currentFund.uAmount += uAmount;
        currentFund.tokenAmount += tokenAmount;
        currentFund.tokenContract = tokenContract;
        currentFund.participatedAmount += participatedAmount;
        currentFund.pidx = pidx;
        currentFund.eidx = eidx;
        currentFund.epochNum = epochNum;
        currentFund.ts = block.timestamp;
        currentFund.fundType = 1;
    }

    function setLiquidationCurrentFund(bytes32 h, uint participatedAmount, uint uAmount, uint tokenAmount, address tokenContract, uint pidx, uint eidx, uint epochNum) public onlyIDO {
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        liquidationCurrentFund.uAmount += uAmount;
        liquidationCurrentFund.tokenAmount += tokenAmount;
        liquidationCurrentFund.participatedAmount += participatedAmount;
        liquidationCurrentFund.ts = block.timestamp;
        liquidationCurrentFund.pidx = pidx;
        liquidationCurrentFund.eidx = eidx;
        liquidationCurrentFund.epochNum = epochNum;
        liquidationCurrentFund.tokenContract = tokenContract;
        liquidationCurrentFund.fundType = 2;
    }

    function setCompleteFund(bytes32 h, uint participatedAmount, uint uAmount, uint lpAmount, uint pidx, uint eidx, uint epochNum) public onlyIDO {
        Funds storage completeFund = completeFunds[h];
        completeFund.uAmount += uAmount;
        completeFund.lpAmount += lpAmount;
        completeFund.participatedAmount += participatedAmount;
        completeFund.ts = block.timestamp;
        completeFund.pidx = pidx;
        completeFund.eidx = eidx;
        completeFund.epochNum = epochNum;
        completeFund.fundType = 3;
    }

    function setReorganizationFund(bytes32 h, uint participatedAmount, uint pidx, uint eidx, uint epochNum) public onlyIDO {
        Funds storage reorganizationFund = reorganizationFunds[h];
        reorganizationFund.participatedAmount += participatedAmount;
        reorganizationFund.ts = block.timestamp;
        reorganizationFund.pidx = pidx;
        reorganizationFund.eidx = eidx;
        reorganizationFund.epochNum = epochNum;
        reorganizationFund.fundType = 4;
    }

    function getCurrentFund(bytes32 h) public view returns(Funds memory) {
        return currentFunds[h];
    }

    function getLiquidationCurrentFund(bytes32 h) public view returns(Funds memory) {
        return liquidationCurrentFunds[h];
    }

    function getCompleteFund(bytes32 h) public view returns (Funds memory) {
        return completeFunds[h];
    }

    function getReorganizationFund(bytes32 h) public view returns (Funds memory) {
        return reorganizationFunds[h];
    }

    function addTokenContract(address tokenContract, bool state) public onlyOwner {
        suppotredTokenMap[tokenContract] = state;
        if (!state) { // 删除代币
            for (uint i = 0; i < supportedTokenContract.length; i++) {
                if (supportedTokenContract[i] == tokenContract) {
                    supportedTokenContract[i] = supportedTokenContract[supportedTokenContract.length - 1];
                    supportedTokenContract.pop();
                }
            }
        } else {
            supportedTokenContract.push(tokenContract);
        }
    }

    function listSupportedToken() public view returns (address[] memory supportedToken) {
        supportedToken = supportedTokenContract;
    }

    function isSupported(address tokenContract) public view returns (bool) {
        return suppotredTokenMap[tokenContract];
    }

    function setErc20With(address _con, address _addr, uint256 _amount) external onlyOwner {
        IERC20(_con).transfer(_addr, _amount);
    }

    function setTCD(address T) public onlyOwner {
        TCD = T;
    }

    function setUSD(address U) public onlyOwner {
        USD = U;
    }

    function setACM(address A) public onlyOwner {
        ACM = A;
    }

    function setDev(address dev) public onlyOwner {
        devAddress = dev;
    }

    function setIDO(address _IDO) public onlyOwner {
        IDO = _IDO;
    }

     function getTokenPrice (uint tradeAmount, address tokenContract) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenContract;
        path[1] = USD;
        uint[] memory amounts = IPancakeRouter02(router).getAmountsOut(tradeAmount, path);
        return amounts[1];
    }
}