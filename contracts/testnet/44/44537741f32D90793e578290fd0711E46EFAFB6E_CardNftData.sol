// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract CardNftData is Ownable {
    using SafeMath for uint256;

    address public logicAddr;

    address public usdtAddr;
    address public sosAddr;
    address public pledgeUsdtAddr;
    address public fenrunAddr;
    address public destroyAddr;

    mapping(string => uint8) public cardStateMapping; //0-未合成;1-已合成;2-已销毁;3-交易锁定

    mapping(uint256 => uint256) public boxNumMapping; //等级 => 数量
    mapping(uint256 => uint256) public boxUsdtNumMapping; //等级 => usdt数量

    uint256 public boxIndex;

    uint256 public buyBoxTimeLimit; //购买盲盒时间限制

    constructor(
        address _usdtAddr,
        address _sosAddr,
        address _pledgeUsdtAddr,
        address _fenrunAddr,
        address _destroyAddr
    ) {
        usdtAddr = _usdtAddr;
        sosAddr = _sosAddr;
        pledgeUsdtAddr = _pledgeUsdtAddr;
        fenrunAddr = _fenrunAddr;
        destroyAddr = _destroyAddr;
    }

    function setLogicAddr(address _addr) public onlyOwner {
        logicAddr = _addr;
    }

    modifier onlyLogicAndOwner() {
        require(
            msg.sender == logicAddr || msg.sender == owner(),
            "only logic and owner"
        );
        _;
    }

    function setCardState(string memory cardId, uint8 state)
        public
        onlyLogicAndOwner
    {
        cardStateMapping[cardId] = state;
    }

    function setBoxNum(uint256 level, uint256 num) public onlyLogicAndOwner {
        boxNumMapping[level] = num;
    }

    function setBoxIndex(uint256 index) public onlyLogicAndOwner {
        boxIndex = index;
    }

    function setPledgeUsdtAddress(address _addr) public onlyLogicAndOwner {
        pledgeUsdtAddr = _addr;
    }

    function setFenRunAddress(address _addr) public onlyLogicAndOwner {
        fenrunAddr = _addr;
    }

    function setDestroyAddress(address _addr) public onlyLogicAndOwner {
        destroyAddr = _addr;
    }

    function configureBoxUsdt(uint256[] memory boxusdtnum)
        public
        onlyLogicAndOwner
    {
        for (uint256 index = 0; index < boxusdtnum.length; index++) {
            boxUsdtNumMapping[index + 1] = boxusdtnum[index];
        }
    }

    function configureBox(
        uint256[] memory boxnum,
        uint256 timestamp,
        bool reset
    ) public onlyLogicAndOwner {
        for (uint256 index = 0; index < boxnum.length; index++) {
            if (reset) {
                boxNumMapping[index + 1] = boxnum[index];
            } else {
                boxNumMapping[index + 1] = boxNumMapping[index + 1].add(
                    boxnum[index]
                );
            }
        }
        buyBoxTimeLimit = timestamp;
    }
}