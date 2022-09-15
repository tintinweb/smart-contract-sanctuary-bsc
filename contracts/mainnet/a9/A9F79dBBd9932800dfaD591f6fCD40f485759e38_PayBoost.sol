//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RocketFi.sol";

interface IFloatieParkControlCenter {
    function getRecipientAddressByRocketID(string memory _rocketID) external view returns (address);
}

interface IDexRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRocketPlayExtended {
    function claimRewards(IERC20 _token, address receiver) external;
}

interface IBurnToEarnExtended {
    function getSharePosition(address holder) external view returns (uint256);
}

// User must approve the PayBoost contract for the desired allowance amount prior to sending.
// User is allowed to send at all times, however there is a cool down built into the RocketPlay contract.

contract PayBoost is Auth {

    RocketFi rocketFi;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public holdRequirement = 50*1e15;
    mapping(IERC20 => uint8) public isAllowed;
    mapping(address => uint8) public claimRewardsOnTransfer;
    
    constructor(RocketFi _rocketFi) Auth(msg.sender) {
        rocketFi = _rocketFi;
    }

    // send an approved bsc token to any smart code recipient and collect RocketFi 
    function sendTokenToSmartCode(IERC20 token, string memory recipientSmartCode, uint256 tokenAmount) public {
        RocketFi _rocketFi = rocketFi;

        address _recipient  = IFloatieParkControlCenter(address(_rocketFi.rocketForge())).getRecipientAddressByRocketID(recipientSmartCode); //grab recipient address;
        bool    _isValid    = _recipient != address(0) && _recipient != msg.sender; //ensure sender != recipient or 0 address;
        require(_isValid && isAllowed[token] == 1 && tokenAmount > 0,'invalid code or recipient');
        
        if(address(_rocketFi) == address(token)) { token.transferFrom(msg.sender, _recipient, tokenAmount); }
        else { 
            uint256 _sharePosition; //fuel position
            try IBurnToEarnExtended(address(_rocketFi.burnToEarn())).getSharePosition(msg.sender)
                returns (uint256 sharePosition) {_sharePosition = sharePosition;} catch {}
            if(_rocketFi.balanceOf(msg.sender) + _sharePosition > holdRequirement) //only collects payboost if rocketfi + fuel balance > 0
                _rocketFi.rocketPlay().playRocketPools(
                    msg.sender,
                    _recipient,
                    RocketLibrary.TransferType.Transfer,
                    getAmountsOutMin(address(token), _rocketFi, tokenAmount)); //outputs estimated RocketFi being sent
            token.transferFrom(msg.sender, _recipient, tokenAmount);
        }
        if(claimRewardsOnTransfer[msg.sender]==1)
            IRocketPlayExtended(address(_rocketFi.rocketPlay())).claimRewards(IERC20(address(_rocketFi)), msg.sender);
    }

    //returns estimated RocketFi Tokens Out amount based on the Token In/AmoutnIn
    function getAmountsOutMin(address tokenIn, RocketFi _rocketFi, uint256 amountIn) public view returns (uint256 _rocketFiAmount) {
        address[] memory path;
        path    = new address[](3);
        path[0] = tokenIn;
        path[1] = WBNB;
        path[2] = address(_rocketFi);

        _rocketFiAmount = IDexRouter(address(_rocketFi.router())).getAmountsOut(amountIn, path)[path.length -1];
    }

    function enableToken(IERC20 token, bool value) external authorized {
        isAllowed[token] = value ? 1 : 0;
    }

    function setClaimOnTransfer(bool value) external {
        claimRewardsOnTransfer[msg.sender] =  value ? 1 : 0;
    }

    //contact RocketFi support if you accidentally sent a token or BNB to the PayBoost contract and need it recovered.
    function reclaimToken(IERC20 token) external authorized {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function transferBNB(address payable _to) external authorized {
        (bool success,) = _to.call{value : address(this).balance}("");
        require(success, "unable to transfer value");
    }

    function updateHoldRequirement(uint256 _holdRequirement) external authorized {
        holdRequirement = _holdRequirement;
    }
}