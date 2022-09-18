// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./DateTime.sol";
import "./IPancakeRouter02.sol";

contract ACMClaim is Ownable {

    struct Funds {
        uint uAmount; // u数量
        uint tokenAmount; // 代币数量
        address tokenContract; // 合约地址
        uint lpAmount; // lp数量
        
    }

    mapping (bytes32 => uint) private fixedParticipatedFunds;
    // 每个地址参与资金
    mapping (bytes32 => uint) private participatedFunds;
    // 当期筹满时每个地址可领取资金
    mapping (bytes32 => Funds) private currentFunds;
    // 当期爆仓清算金额
    mapping (bytes32 => Funds) private liquidationCurrentFunds;
    // 第五期完成时每个地址可领取资金
    mapping (bytes32 => Funds) private completeFunds;
    // U代币
    address public USD;
    // TCD代币
    address public TCD;
    // ACM 代币
    address public ACM;
    // 销毁地址
    address public deathAddress = address(0);
    // 管理员地址
    address public devAddress;
    uint public remainingACMSupply = 1540000000000000000000000;
    // 合约地址到交易路由的映射
    mapping (address => address) private tokenContractToRouter;
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
        require (currentFund.uAmount > 0, "No quantity available");
        uint uAmount = currentFund.uAmount;
        uint tokenAmount = currentFund.tokenAmount;
        currentFund.uAmount = 0;
        currentFund.tokenAmount = 0;
        // 只有代币为ACM才会销毁，否则不销毁
        if ( tokenAmount > 0 && currentFund.tokenContract == ACM) {
            IERC20(ACM).transfer(deathAddress, tokenAmount);
        }

        // 返还U
        if (uAmount > 0) {
            IERC20(USD).transfer(to, uAmount);
        }
    }

     // 领取当期爆仓资金
    function receiveLiquidationCurrentFunds(bytes32 h, address to) public onlyIDO {
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        require (liquidationCurrentFund.uAmount > 0, "No quantity available");
        uint uAmount = liquidationCurrentFund.uAmount;
        uint tokenAmount = liquidationCurrentFund.tokenAmount;
        liquidationCurrentFund.uAmount = 0;
        liquidationCurrentFund.tokenAmount = 0;
        IERC20 token = IERC20(liquidationCurrentFund.tokenContract);
        // 返还代币和U ACM总量145万，ACM总量没反完之前会一直反双倍，否则没有双倍
        if (tokenAmount > 0) {
            if (liquidationCurrentFund.tokenContract == ACM && remainingACMSupply >= tokenAmount * 2 && token.balanceOf(address(this)) >= tokenAmount * 2) {
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
        require (completeFund.uAmount > 0, "No quantity available");
        uint uAmount = completeFund.uAmount;
        uint lpAmount = completeFund.lpAmount;
        completeFund.uAmount = 0;
        completeFund.lpAmount = 0;
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
        require (participatedFunds[h] > 0, "No quantity available");
        // 能组LP的额度
        uint lpAmount = subStageAmount * participatedFunds[h] / totalAmount;
        participatedFunds[h] = 0;
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

        IERC20(USD).approve(tokenContractToRouter[TCD], tokenAmount);

        // make the swap
        IPancakeRouter02(tokenContractToRouter[TCD]).swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
        IPancakeRouter02 router = IPancakeRouter02(tokenContractToRouter[TCD]);
        IERC20(TCD).approve(address(router), tokenAmount);
        IERC20(USD).approve(address(router), uAmount);

        // add the liquidityswapExactTokensForTokensSupportingFeeOnTransferTokens
        router.addLiquidity(
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

    function getFixedParticipatedFund(bytes32 h) public view returns (uint) {
        return fixedParticipatedFunds[h];
    }

    function setCurrentFund(bytes32 h, uint uAmount, uint tokenAmount, address tokenContract) public onlyIDO {
        Funds storage currentFund = currentFunds[h];
        currentFund.uAmount += uAmount;
        currentFund.tokenAmount += tokenAmount;
        currentFund.tokenContract = tokenContract;
    }

    function setLiquidationCurrentFund(bytes32 h, uint uAmount, uint tokenAmount, address tokenContract) public onlyIDO {
        Funds storage liquidationCurrentFund = liquidationCurrentFunds[h];
        liquidationCurrentFund.uAmount += uAmount;
        liquidationCurrentFund.tokenAmount += tokenAmount;
        liquidationCurrentFund.tokenContract = tokenContract;
    }

    function setCompleteFund(bytes32 h, uint uAmount, uint lpAmount) public onlyIDO {
        Funds storage completeFund = completeFunds[h];
        completeFund.uAmount += uAmount;
        completeFund.lpAmount += lpAmount;
    }

    function setParticipatedFund(bytes32 h, uint amount) public onlyIDO {
        participatedFunds[h] += amount;
    }

    function setFixedParticipatedFund(bytes32 h, uint amount) public onlyIDO {
        fixedParticipatedFunds[h] += amount;
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

    function getParticipatedFund(bytes32 h) public view returns (uint) {
        return participatedFunds[h];
    }

    function addTokenContract(address tokenContract, address tokenRouter) public onlyOwner {
        tokenContractToRouter[tokenContract] = tokenRouter;
        if (tokenRouter == address(0)) { // 删除代币
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

    function getTokenContractToRouter(address tokenContract) public view returns (address) {
        return tokenContractToRouter[tokenContract];
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

    function setIDO(address I) public onlyOwner {
        IDO = I;
    }
}