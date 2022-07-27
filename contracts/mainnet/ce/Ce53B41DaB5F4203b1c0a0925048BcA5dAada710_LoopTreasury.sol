// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
pragma solidity ^0.8.0;

import "./ITreasury.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IMiner.sol";

contract LoopTreasury is ITreasury,Ownable,IMiner{
    using SafeMath for uint256;

    mapping(address=>bool)public miner;
    address public tokenAddress;
    mapping(uint256=>address) public rewards;
    mapping(address => bool) public pancakeV2Pairs;
    
    event TakeReward(address sender,uint256 feeAmount);

    function notify(address from, address to,uint256 amount,uint256 feeAmount)external override{
        if(tokenAddress !=address(0) && msg.sender == tokenAddress && amount != 0){
            if(pancakeV2Pairs[from]){
                IERC20(tokenAddress).transfer(rewards[0], feeAmount);
                emit TakeReward(address(this),feeAmount);
            }else if(pancakeV2Pairs[to]){
                IERC20(tokenAddress).transfer(rewards[1], feeAmount.div(10000).mul(4000));
                IERC20(tokenAddress).transfer(rewards[2], feeAmount.div(10000).mul(4000));
                IERC20(tokenAddress).transfer(rewards[3], feeAmount.div(10000).mul(2000));
                emit TakeReward(address(this),feeAmount);
            }
        }
    }

    function addliquidityPairs(address liquidityPairAddress_) public virtual onlyOwner returns(bool){
        _addLiquidityPairs(liquidityPairAddress_);
        return true;
    }

    function setTokenAddress(address _tokenAddress) public virtual onlyOwner returns(bool){
        tokenAddress = _tokenAddress;
        return true;
    }

    function setRewardAddress(uint256 _index, address _rewardAddress) public virtual onlyOwner returns(bool){
        rewards[_index] = _rewardAddress;
        return true;
    }

    function _addLiquidityPairs(address liquidityPairAddress_) private returns(bool){
        if(pancakeV2Pairs[liquidityPairAddress_]){
            pancakeV2Pairs[liquidityPairAddress_] = false;
        }else{
             pancakeV2Pairs[liquidityPairAddress_] = true;
        }
        return true;
    }

    function mint(address _to,uint256 _amount)external override returns(bool){
        require(miner[msg.sender],"sender not is miner");
        IERC20(tokenAddress).transfer(_to, _amount);
        return true;
    }

    function addMiner(address _miner)public virtual onlyOwner returns(bool){
        if(miner[_miner]){
            miner[_miner] = false;
        }else{
             miner[_miner] = true;
        }
        return true;
    }

}