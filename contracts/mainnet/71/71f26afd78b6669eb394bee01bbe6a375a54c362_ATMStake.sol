/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}

interface IUniswapV2Router02 {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract ATMStake is Ownable {
    address constant public USDTToken = address(0x55d398326f99059fF775485246999027B3197955);    
    address constant public ATMToken = address(0x5304D049a629cFDDa53f675a0D18141cD46EC3C2);
    uint256 constant public ATMDecimal = 1e18;
    IUniswapV2Router02 constant private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint256 public releaseBasePrice = 10;  
    uint256 public releaseIncrementPercent = 20;  
    bool public canEarlyUnStake;  


    struct UpgradeInfo {
        uint256 upgradeTime;        
        uint256 upgradePrice;       
        uint256 upgradeATMTotal; 
        uint256 upgradeCanRewardATMTotal;   
        uint256 upgradeRewardATM;    
        uint256 upgradeRewardUSDT;  
        uint256 upgradePreviousToThisATMAmt; 
    }
    UpgradeInfo[] public upgradeInfos;  


    struct StakeInfo {
        address user;   
        uint256 time;    
        uint256 stakeAmt;  
        uint256 releasedAmt; 
        uint256 rewardATM;   
        uint256 rewardUSDT; 
    }
    StakeInfo[] public stakeInfos;  
    mapping (address => uint256[]) public stakeUserIdx;  

    mapping (address => uint256) public userStakeAmt;  
    mapping (address => uint256) public userReleasedAmt;  
    mapping (address => uint256) public userWithdrawedAmt; 
    mapping (address => bool) public userAbandoned;  

    mapping (address => uint256) public userRewardATMAmt; 
    mapping (address => uint256) public userRewardWithdrawedATMAmt; 
    mapping (address => uint256) public userRewardUSDTAmt;  
    mapping (address => uint256) public userRewardWithdrawedUSDTAmt;  

    uint256 public sysStakeAmt; 
    uint256 public sysCurStakeAmt; 

    uint256 public rewardUSDTAmt; 
    uint256 public rewardATMAmt; 
    uint256 public alreadyRewardUSDTAmt;
    uint256 public alreadyRewardATMAmt; 
    uint256 public rewardUSDTEachTime; 
    uint256 public rewardATMEachTime; 

    constructor() {
    }

    receive() external payable{}

    function deposit() external payable {}


    function setRewardInfo(address tokenAddr_, uint256 rewardAmt_, uint256 rewardEachTime_) external onlyOwner {
        require(rewardEachTime_ > 0, "setRewardInfo: Each time reward min than zero.");
        require(rewardAmt_ >= rewardEachTime_, "setRewardInfo: Each time reward max than total.");
        require(tokenAddr_ == USDTToken || tokenAddr_ == ATMToken, "setRewardInfo: TokenAddr Error.");

        if (tokenAddr_ == USDTToken) {
            rewardUSDTAmt += rewardAmt_;
            if (rewardUSDTEachTime == 0) { 
                rewardUSDTEachTime = rewardEachTime_;
            }
        } else {
            rewardATMAmt += rewardAmt_;
            if (rewardATMEachTime == 0) {  
                rewardATMEachTime = rewardEachTime_;
            }
        }


        TransferHelper.safeTransferFrom(tokenAddr_, _msgSender(), address(this), rewardAmt_);
    }

    function getSummary(address user) public view returns(
        uint256 sysStakeAmt_,
        uint256 sysCurStakeAmt_,
        uint256 userStakeAmt_, 
        uint256 userReleasedAmt_,
        uint256 userWithdrawedAmt_,
        uint256 userRewardATMAmt_,
        uint256 userRewardWithdrawedATMAmt_,
        uint256 userRewardUSDTAmt_,
        uint256 userRewardWithdrawedUSDTAmt_
    ) {
        sysStakeAmt_ = sysStakeAmt;
        sysCurStakeAmt_ = sysCurStakeAmt;
        userStakeAmt_ = userStakeAmt[user];

        userWithdrawedAmt_ = userWithdrawedAmt[user];
        userRewardWithdrawedATMAmt_ = userRewardWithdrawedATMAmt[user];
        userRewardWithdrawedUSDTAmt_ = userRewardWithdrawedUSDTAmt[user];

        StakeInfo[] memory _stakeInfos = getStakeInfos(user);
        for(uint256 i = 0; i < _stakeInfos.length; i ++) {
            userReleasedAmt_ += _stakeInfos[i].releasedAmt;
            userRewardATMAmt_ += _stakeInfos[i].rewardATM;
            userRewardUSDTAmt_ += _stakeInfos[i].rewardUSDT;
        }
    }

    function getStakeInfos(address user) public view returns(StakeInfo[] memory _stakeInfos) {
        uint256[] memory idxs = stakeUserIdx[user];
        uint256 j; 
        uint256 shouldRelease;

        _stakeInfos = new StakeInfo[](idxs.length);

        for(uint256 i = 0; i < idxs.length; i ++) {
            _stakeInfos[i] = stakeInfos[idxs[i]];
            if (upgradeInfos.length == 0) { 
                continue;
            }

            for (; j < upgradeInfos.length; ) {
                if (_stakeInfos[i].time < upgradeInfos[j].upgradeTime) {

                    if (_stakeInfos[i].releasedAmt < _stakeInfos[i].stakeAmt) { 
                        shouldRelease = _stakeInfos[i].stakeAmt * (upgradeInfos.length - j) * 10 / 100;
                        if (shouldRelease < _stakeInfos[i].stakeAmt) {
                            _stakeInfos[i].releasedAmt = shouldRelease;
                        } else {
                            _stakeInfos[i].releasedAmt = _stakeInfos[i].stakeAmt;
                        }
                    }

       
                    uint256 shouldRewardATM;
                    uint256 shouldRewardUSDT;
                    for(uint k = j; k < upgradeInfos.length; k ++) {
                        if (k - j >= 10) {  
                            break;
                        }

                        if (upgradeInfos[k].upgradeCanRewardATMTotal == 0) {
                            continue;
                        }

                        shouldRewardATM += 
                            (stakeInfos[idxs[i]].stakeAmt * (10 + j - k) * 10 / 100) * 
                            (upgradeInfos[k].upgradeRewardATM * 1e10 / upgradeInfos[k].upgradeCanRewardATMTotal)
                            / 1e10;

                        shouldRewardUSDT += 
                            (stakeInfos[idxs[i]].stakeAmt * (10 + j - k) * 10 / 100) * 
                            (upgradeInfos[k].upgradeRewardUSDT * 1e10 / upgradeInfos[k].upgradeCanRewardATMTotal)
                            / 1e10;
                    }

                    _stakeInfos[i].rewardATM = shouldRewardATM;
                    _stakeInfos[i].rewardUSDT = shouldRewardUSDT;

                    break; 
                }

                j ++;
            }
        }

        return _stakeInfos;
    }


    function needRelease() public view returns(uint256 ret) {
        if (upgradeInfos.length == 0 && getCurPrice() >= releaseBasePrice * 1e18) {  
            ret = 1;
        } else if (upgradeInfos.length > 0  && getCurPrice() >= upgradeInfos[upgradeInfos.length - 1].upgradePrice * (100 + releaseIncrementPercent) / 100) { 
            ret = 1;
        } else {
            ret = 0;
        }
    }
    


    function sysRelease() public returns(bool) {
        require(needRelease() == 1, "Cannot Release.");

        UpgradeInfo memory ui;

        if (upgradeInfos.length == 0) {  
            ui.upgradePrice = releaseBasePrice * 1e18;
            ui.upgradePreviousToThisATMAmt = sysStakeAmt;
            ui.upgradeCanRewardATMTotal = sysStakeAmt;
        } else {  
            ui.upgradePrice = upgradeInfos[upgradeInfos.length - 1].upgradePrice * (100 + releaseIncrementPercent) / 100;
            ui.upgradePreviousToThisATMAmt = sysStakeAmt - upgradeInfos[upgradeInfos.length - 1].upgradeATMTotal;

      
            uint j = 1;
            sysCurStakeAmt = ui.upgradePreviousToThisATMAmt; 
            for(uint i = upgradeInfos.length - 1; i >= 0;) {
                sysCurStakeAmt += upgradeInfos[i].upgradePreviousToThisATMAmt - upgradeInfos[i].upgradePreviousToThisATMAmt * j * 10 / 100;
                if (i == 0) {
                    break;
                } else {
                    i --;
                }

                j ++;
                if (j >= 10) { 
                    break;
                }
            }
            ui.upgradeCanRewardATMTotal = sysCurStakeAmt;
        }
        ui.upgradeATMTotal = sysStakeAmt;
        ui.upgradeTime = block.timestamp;

        if (rewardUSDTAmt - alreadyRewardUSDTAmt >= rewardUSDTEachTime) {
            ui.upgradeRewardUSDT = rewardUSDTEachTime;
            alreadyRewardUSDTAmt += rewardUSDTEachTime;
        }

        if (rewardATMAmt - alreadyRewardATMAmt >= rewardATMEachTime) {
            ui.upgradeRewardATM = rewardATMEachTime;
            alreadyRewardATMAmt += rewardATMEachTime;
        }

        upgradeInfos.push(ui);

        return true;
    }

    function userRelease(address user) private {
        require(upgradeInfos.length > 0, "balance not enough");
        require(!userAbandoned[user], "Account voided.");

        uint256[] memory idxs = stakeUserIdx[user];
        uint256 j; 
        uint256 shouldRelease;
        uint256 shouldRewardATM;
        uint256 shouldRewardUSDT;

        userRewardATMAmt[user] = 0;  
        userRewardUSDTAmt[user] = 0;

        for(uint256 i = 0; i < idxs.length; i ++) {
            for (; j < upgradeInfos.length; ) {
                if (stakeInfos[idxs[i]].time < upgradeInfos[j].upgradeTime) {

                    if (stakeInfos[idxs[i]].releasedAmt < stakeInfos[idxs[i]].stakeAmt) {
                        shouldRelease = stakeInfos[idxs[i]].stakeAmt * (upgradeInfos.length - j) * 10 / 100;
                        
                        if (shouldRelease < stakeInfos[idxs[i]].stakeAmt) {
                            userReleasedAmt[user] += shouldRelease - stakeInfos[idxs[i]].releasedAmt;
                            stakeInfos[idxs[i]].releasedAmt = shouldRelease;
                        } else {
                            userReleasedAmt[user] += stakeInfos[idxs[i]].stakeAmt - stakeInfos[idxs[i]].releasedAmt;
                            stakeInfos[idxs[i]].releasedAmt = stakeInfos[idxs[i]].stakeAmt;
                        }
                    }


                    shouldRewardATM = 0;
                    shouldRewardUSDT = 0;
                    for(uint k = j; k < upgradeInfos.length; k ++) {
                        if (k - j >= 10) { 
                            break;
                        }

                        if (upgradeInfos[k].upgradeCanRewardATMTotal == 0) {
                            continue;
                        }

                        shouldRewardATM += 
                            (stakeInfos[idxs[i]].stakeAmt * (10 + j - k) * 10 / 100) * 
                            (upgradeInfos[k].upgradeRewardATM * 1e10 / upgradeInfos[k].upgradeCanRewardATMTotal)
                            / 1e10;

                        shouldRewardUSDT += 
                            (stakeInfos[idxs[i]].stakeAmt * (10 + j - k) * 10 / 100) * 
                            (upgradeInfos[k].upgradeRewardUSDT * 1e10 / upgradeInfos[k].upgradeCanRewardATMTotal)
                            / 1e10;
                    }

                    userRewardATMAmt[user] += shouldRewardATM;
                    userRewardUSDTAmt[user] += shouldRewardUSDT;

                    break; 
                }

                j ++;
            }
        }
    }

    function stakeAMT(uint256 amountToken) external {
        require(_msgSender() == tx.origin, "stakeAMT: Can't From Contract.");
        require(amountToken >= 100 * 1e18, "stakeAMT: Token amount is too small.");
        require(stakeUserIdx[_msgSender()].length < 10, "stakeAMT: Up to ten orders per account.");
        require(!userAbandoned[_msgSender()], "Account voided.");


        TransferHelper.safeTransferFrom(ATMToken, _msgSender(), address(this), amountToken);

        StakeInfo memory di = StakeInfo({
            user: _msgSender(), 
            time: block.timestamp, 
            stakeAmt: amountToken, 
            releasedAmt: 0,
            rewardATM: 0,
            rewardUSDT: 0
        });
        stakeInfos.push(di);
        stakeUserIdx[_msgSender()].push(stakeInfos.length - 1);  

        userStakeAmt[_msgSender()] += amountToken;
        sysStakeAmt += amountToken;
        sysCurStakeAmt += amountToken;
    }

    function getCurPrice() public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = ATMToken;
        path[1] = USDTToken;
        uint[] memory amounts = uniswapV2Router.getAmountsOut(1e18, path);
        if (amounts[0] == 0 || amounts[1] == 0) {
            return 0;
        }
        return amounts[1] * 1e18 / amounts[0];
    }

    function userWithdrawFund() public returns (bool){
        userRelease(_msgSender()); 

        uint256 canWithdrawToken1 = userReleasedAmt[_msgSender()] - userWithdrawedAmt[_msgSender()];
        uint256 canWithdrawToken2 = userRewardATMAmt[_msgSender()] - userRewardWithdrawedATMAmt[_msgSender()];
        require(canWithdrawToken1 + canWithdrawToken2 > 0, "balance not enough");
        require(canWithdrawToken1 + canWithdrawToken2 <= IERC20(ATMToken).balanceOf(address(this)), "system balance not enough");

        userWithdrawedAmt[_msgSender()] += canWithdrawToken1;
        userRewardWithdrawedATMAmt[_msgSender()] += canWithdrawToken2;

        TransferHelper.safeTransfer(ATMToken, _msgSender(), canWithdrawToken1 + canWithdrawToken2);


        // USDT
        uint256 canWithdrawToken3 = userRewardUSDTAmt[_msgSender()] - userRewardWithdrawedUSDTAmt[_msgSender()];
        
        if (canWithdrawToken3 > 0) {
            require(canWithdrawToken3 <= IERC20(USDTToken).balanceOf(address(this)), "system balance not enough");

            userRewardWithdrawedUSDTAmt[_msgSender()] += canWithdrawToken3;

            TransferHelper.safeTransfer(USDTToken, _msgSender(), canWithdrawToken3);
        }

        return true;
    }

    function userWithdrawFundEarly() public returns (bool) { 
        require(canEarlyUnStake, "Cannot early unstake.");
        require(!userAbandoned[_msgSender()], "Account voided.");

        uint256[] memory idxs = stakeUserIdx[_msgSender()];
        userReleasedAmt[_msgSender()] = 0;
        for(uint256 i = 0; i < idxs.length; i ++) {
            userReleasedAmt[_msgSender()] += stakeInfos[idxs[i]].stakeAmt;
            stakeInfos[idxs[i]].releasedAmt = stakeInfos[idxs[i]].stakeAmt;
        }

        userAbandoned[_msgSender()] = true;

        uint256 canWithdrawToken = userReleasedAmt[_msgSender()] - userWithdrawedAmt[_msgSender()];  
        require(canWithdrawToken > 0, "balance not enough");
        require(canWithdrawToken <= IERC20(ATMToken).balanceOf(address(this)), "system balance not enough");

        userWithdrawedAmt[_msgSender()] += canWithdrawToken;

        TransferHelper.safeTransfer(ATMToken, _msgSender(), canWithdrawToken);

        return true;
    }

    function setParam(uint256 releaseBasePrice_, uint256 releaseIncrementPercent_) public onlyOwner {
        releaseBasePrice = releaseBasePrice_;
        releaseIncrementPercent = releaseIncrementPercent_;
    }

    function setCanEarlyUnStake(bool canEarlyUnStake_) public onlyOwner {
        canEarlyUnStake = canEarlyUnStake_;
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {
        TransferHelper.safeTransfer(tokenAddress, owner(), tokens);
        return true;
    }

    function rescueETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}