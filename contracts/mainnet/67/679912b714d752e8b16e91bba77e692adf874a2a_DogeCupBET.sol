/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

/*

    dogecup.com
    https://t.me/dogecupofficial
    https://t.me/dogecupnews
    https://twitter.com/Dogecupofficial
    FARM NFT, STAKE, BET SOCCER

*/

pragma solidity ^0.8.0;


abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
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

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }


    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (uint256);    

    function transfer(address to, uint256 amount) external returns (bool);
}


interface IWrapperDaoDCUP {
    function depositFor_AdressProject(address account, uint256 amount) external;

    function withdrawTo_AdressProject(address account, uint256 amount) external;

}

interface IReadAddressThis {

    struct betInfos {
        uint256[] amountTokens;
        uint256[] whatsBet;
        uint256[] whatsMyBetPool;
        uint256[] numberBet;
        bool[] isBetWinner;
        uint256[] earnWithdrawled;

    }

    function getMappingBetInfos(address better)
        external
        view
        returns (
            uint256[] memory,uint256[] memory,uint256[] memory,
            uint256[] memory,uint256[] memory,bool[] memory,
            uint256[] memory);

}

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}



contract DogeCupBET is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 public feesProject;
    uint256 public feesNetwork;
    uint256 public amountTokensInBet;
    uint256 public amountTokensClaimed;
    uint256 public amountFeesTake;

    uint256 public totalBetMade;
    uint256 public whatsBetMade;

    uint256 public timeDeployContractThis;
    uint256 public timeOpenBet;
    bool public settedTimeOpenPoolBet;
    bool public checkSecurityActived;

    uint256 public minimumForBet;

    mapping(address => bool) public mappingAuth;

    address public   addressDogeCUP =    0xcEf365B5932558c7E3212053f99634F3D9e078bA;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
/*
    address public   addressDogeCUP =    0x5947a0EE2c33e24BE35502A671036A7eC2f7f5B7;
    address internal addressBUSD =      0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address internal addressWBNB =      0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address internal addressPCVS2  =    0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

*/
    address public   burnWallet = 0xFa9ed83e12b651c987DF7201A4A4f6ee8B1185D7;
    address public   authAddress = 0xc1C797a2332CA275eeb5E38F5F06D389C16175DE;

    struct betInfos {
        uint256[50]     amountTokens;
        bool[50]        isBetter;
        uint256[50]     whatsMyBetPool;
        bool[50]        isBetWinner;
        uint256[50]     earnWithdrawled;
        uint256[50]     myAPR;
    }

    address[] public allAddressBet;

    mapping(address => betInfos) mappingBetInfos;
    mapping(address => bool) mappingBetting;

    mapping(uint256 => uint256) public amountTokensOnBet;
    mapping(uint256 => uint256) public amountTokensOnFirstPoolBet;
    mapping(uint256 => uint256) public amountTokensOnSecondPoolBet;
    mapping(uint256 => uint256) public totalBetPool1;
    mapping(uint256 => uint256) public totalBetPool2;

    mapping(uint256 => uint256) public resultFinalBet; //bit 1 or 2
    mapping(uint256 => bool) public openBet; //bool 1 or 0
    mapping(uint256 => string) public betName;
    mapping(uint256 => string) public descrption;

    event betEvent(
        address indexed addressBetter, 
        uint256 amountTokens, 
        uint256 whatsBet,
        uint256 whatsMyBetPool
    );

    event betEarnClaimed(
        address indexed addressBetter, 
        uint256 whatsBet,
        uint256 amountTokens, 
        uint256 getWinOfBet
    );
    
    receive() external payable {}

    constructor() {
        timeDeployContractThis = block.timestamp;
        feesProject = 150;
        feesNetwork = 1 ether / 3200;
        checkSecurityActived = true;
        minimumForBet = 1000 * 10 ** 18;
        timeOpenBet = block.timestamp;
        mappingAuth[authAddress] = true;
    }

    modifier onlyAuth() {
        require(_msgSender() == owner() || mappingAuth[_msgSender()], "Not authorized");
        _;
    }

    function getMappingAuth(address account) public view returns (bool){
        return mappingAuth[account]; 
    }

    function getDaysPassed() public view returns (uint256){
        return (block.timestamp - timeOpenBet).div(1 days); 
    }

    function returnHex(string memory word) public pure returns (bytes32) {
        return (keccak256(abi.encodePacked(word)));
    }

    function getMappingBetInfos(address better) public view returns (betInfos memory) {
        return mappingBetInfos[better];
    }

    function getIsBetter(address better, uint256 whatsBet) public view returns (bool) {
        return mappingBetInfos[better].isBetter[whatsBet];
    }

    function getWhatsMyBetPool(address better, uint256 whatsBet) public view returns (uint256) {
        return mappingBetInfos[better].whatsMyBetPool[whatsBet];
    }

    function checkSecurity (address account) public view returns (bool checkSecurityReturn) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        if (size == 0 && tx.origin == account) {
            checkSecurityReturn = true;
        } else {
            require(false,"Failed security check");
        }

        return checkSecurityReturn;
    }

    //whatsBet is 1 or 2 for each of the pools
    //Returns the result of winnings for a specific bet    
    function estimateAPR(address better, uint256 whatsBet) public view returns (
        uint256 amountEarnBet, uint256
        ) {

        uint256 amountTokens = mappingBetInfos[better].amountTokens[whatsBet];
        uint256 whatsMyBetPool = mappingBetInfos[better].whatsMyBetPool[whatsBet];

        if (whatsMyBetPool != resultFinalBet[whatsBet]) 
        return (mappingBetInfos[better].earnWithdrawled[whatsBet],
                mappingBetInfos[better].myAPR[whatsBet]);

        uint256 totalTokensPoolWinners;
        uint256 totalTokensPoolLosers;

        if (whatsMyBetPool == 1) {
            //second pool used for pay
            totalTokensPoolWinners = amountTokensOnFirstPoolBet[whatsBet];
            totalTokensPoolLosers = amountTokensOnSecondPoolBet[whatsBet];

        } if(whatsMyBetPool == 2) {
            //first pool used for pay
            totalTokensPoolWinners = amountTokensOnSecondPoolBet[whatsBet];
            totalTokensPoolLosers = amountTokensOnFirstPoolBet[whatsBet];
        }

        if (totalTokensPoolWinners == 0 || amountTokens == 0) return (0,0);

        amountEarnBet = ((amountTokens  * totalTokensPoolLosers) / totalTokensPoolWinners);

        uint256 amountFeesProject = amountEarnBet * feesProject / 1000;

        amountEarnBet = amountEarnBet - amountFeesProject;


        // Result must be divided by 10 ** 10
        return (amountEarnBet, (amountEarnBet * 10 ** 10) / amountTokens);
    }

    //Returns the APR earnings for a pool if it is the winner
    function estimateAPR_geral(uint256 whatsBet, uint256 whatsMyBetPool) public view returns (
        uint256 estimate) {

        uint256 totalTokensPoolWinners;
        uint256 totalTokensPoolLosers;


        if (whatsMyBetPool == 1) {
            //second pool used for pay
            totalTokensPoolWinners = amountTokensOnFirstPoolBet[whatsBet];
            totalTokensPoolLosers = amountTokensOnSecondPoolBet[whatsBet];

        } if(whatsMyBetPool == 2) {
            //first pool used for pay
            totalTokensPoolWinners = amountTokensOnSecondPoolBet[whatsBet];
            totalTokensPoolLosers = amountTokensOnFirstPoolBet[whatsBet];
        }

        if (totalTokensPoolLosers == 0) return (0);

        //Result must be divided by 10 ** 5
        return ((totalTokensPoolWinners * 10 ** 5) / totalTokensPoolLosers);
    }

    function getInfosBet(address better, uint256 whatsBet) public view returns (
        uint256 amountTokens, bool isBetter, 
        uint256 whatsMyBetPool, bool isBetWinner,
        uint256 earnWithdrawled, uint256 myAPR) {

        amountTokens = mappingBetInfos[better].amountTokens[whatsBet];
        isBetter = mappingBetInfos[better].isBetter[whatsBet];
        whatsMyBetPool = mappingBetInfos[better].whatsMyBetPool[whatsBet];
        isBetWinner = mappingBetInfos[better].isBetWinner[whatsBet];
        earnWithdrawled = mappingBetInfos[better].earnWithdrawled[whatsBet];
        myAPR = mappingBetInfos[better].myAPR[whatsBet];

    }

    function getEarnOfBet(
        address better,
        uint256 whatsBet)
        public 
        view 
        returns 
        (uint256 amountEarnBet, uint256 amountFeesProject, uint256 APR) {

        uint256 amountTokens = mappingBetInfos[better].amountTokens[whatsBet];
        uint256 whatsMyBetPool = mappingBetInfos[better].whatsMyBetPool[whatsBet];

        uint256 totalTokensPoolWinners;
        uint256 totalTokensPoolLosers;

        /*
            The result of winnings is calculated as a share in the opposing pool, if
            the opposing pool has lost the bet
            So if you bet on outcome 1 and that is the winning outcome then opponent pool 2 is used
            as liquidity to pay the winners
        */
        
        uint256 resultOfBet = resultFinalBet[whatsBet];
 
        if (whatsMyBetPool == resultOfBet) {

            if (resultOfBet == 1) {
                //second pool used for pay
                totalTokensPoolWinners = amountTokensOnFirstPoolBet[whatsBet];
                totalTokensPoolLosers = amountTokensOnSecondPoolBet[whatsBet];

            } if(resultOfBet == 2) {
                //first pool used for pay
                totalTokensPoolWinners = amountTokensOnSecondPoolBet[whatsBet];
                totalTokensPoolLosers = amountTokensOnFirstPoolBet[whatsBet];
            }

            if (totalTokensPoolWinners == 0 || amountTokens == 0) return (0,0,0);

            amountEarnBet = 
            (amountTokens  * totalTokensPoolLosers / totalTokensPoolWinners);

            amountFeesProject = amountEarnBet * feesProject / 1000;

            amountEarnBet = amountEarnBet - amountFeesProject;

            APR = (amountEarnBet * 10 ** 10) / amountTokens;

        } else {
            return (0,0,0);

        }
       
        return (amountEarnBet,amountFeesProject,APR);  
    }

    function setStringsBet(
        uint256 _whatsBet,
        string memory stringBetName,
        string memory stringDdescrption) external onlyAuth() {
            
        betName[_whatsBet] = stringBetName;
        descrption[_whatsBet] = stringDdescrption;

    }

    function getIsValidBet(
        uint256 whatsBet)
        public 
        view 
        returns 
        (bool isValid) {

        isValid = true;

        if (amountTokensOnFirstPoolBet[whatsBet] == 0 ||
            amountTokensOnSecondPoolBet[whatsBet] == 0 ) {
                
            isValid = false;
        } 

        return isValid;
    }


    function setInfosBet(
        uint256 _whatsBet, 
        uint256 _whatsResultBet, 
        bool _isOpenBet) external onlyAuth {
        //whatsResultBet is 1 or 2

        if (_whatsBet > whatsBetMade) {
            if (resultFinalBet[_whatsBet] == 0 && 
                openBet[_whatsBet] == false && 
                _whatsResultBet == 0 &&
                _isOpenBet == true
                ) {
                whatsBetMade ++;
                openBet[_whatsBet] = _isOpenBet;
            }
        }

        openBet[_whatsBet] = _isOpenBet;
        resultFinalBet[_whatsBet] = _whatsResultBet; 

    }

    //whatsBet is the number of bets counter
    function betting(
        uint256 amountTokens,
        uint256 whatsBet,
        uint256 whatsMyBetPool)
        external payable
        whenNotPaused 
        nonReentrant() {

        require(timeOpenBet != 0, "Betting pools are not yet open");
        require(whatsMyBetPool == 1 || whatsMyBetPool == 2, "Invalid bet");
        require(amountTokens <= IERC20(addressDogeCUP).balanceOf(_msgSender()), "No balance to bet");
        require(openBet[whatsBet] && resultFinalBet[whatsBet] == 0, "Out of time to bet");
        require(amountTokens >= minimumForBet, "You have to bet more than the minimum");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 amountTokensBetted;

        if(!getIsBetter(_msgSender(),whatsBet)) {
            allAddressBet.push(msg.sender);
        }

        IERC20(addressDogeCUP).transferFrom(msg.sender, address(this), amountTokens);
        require(msg.value == feesNetwork, "Invalid value transferred");
        (bool success,) = authAddress.call{value: feesNetwork}("");
        require(success, "Failed to send BNB");

        amountTokensBetted += amountTokens;

        if (whatsMyBetPool == 1) {

            if (getWhatsMyBetPool(msg.sender,whatsBet) == 1 || getWhatsMyBetPool(msg.sender,whatsBet) == 0) {
                amountTokensOnFirstPoolBet[whatsBet] += amountTokens;
            } else if (
                getWhatsMyBetPool(msg.sender,whatsBet) == 2) {
                amountTokensBetted = mappingBetInfos[msg.sender].amountTokens[whatsBet];
                amountTokensOnSecondPoolBet[whatsBet] -= amountTokensBetted;
                amountTokensOnFirstPoolBet[whatsBet] += (amountTokens + amountTokensBetted);
            }
            totalBetPool1[whatsBet] ++;

        } else if (whatsMyBetPool == 2) {
            if (getWhatsMyBetPool(msg.sender,whatsBet) == 2 ||  getWhatsMyBetPool(msg.sender,whatsBet) == 0) {
                amountTokensOnSecondPoolBet[whatsBet] += amountTokens;

            } else if (
                getWhatsMyBetPool(msg.sender,whatsBet) == 1) {
                amountTokensBetted = mappingBetInfos[msg.sender].amountTokens[whatsBet];
                amountTokensOnFirstPoolBet[whatsBet] -= amountTokensBetted;
                amountTokensOnSecondPoolBet[whatsBet] += (amountTokens + amountTokensBetted);
            }
            totalBetPool2[whatsBet] ++;

        }

        mappingBetInfos[msg.sender].amountTokens[whatsBet] += amountTokens;
        mappingBetInfos[msg.sender].isBetter[whatsBet] = true;
        mappingBetInfos[msg.sender].whatsMyBetPool[whatsBet] = whatsMyBetPool;

        totalBetMade ++;
        amountTokensOnBet[whatsBet] += amountTokens;
        amountTokensInBet += amountTokens;

        emit betEvent(
            msg.sender, 
            amountTokens, 
            whatsBet,
            whatsMyBetPool);
    }

    //In case of a tie all funds are returned, no fees
    //In case one of the pools has no bets and it wins, the funds are returned 
    function claimBettingEarning(
        uint256 whatsBet)
        external payable
        whenNotPaused() 
        nonReentrant() {

        require(timeOpenBet != 0, "Betting pools are not yet open");
        require(msg.value == feesNetwork, "Invalid value transferred");
        (bool success,) = authAddress.call{value: feesNetwork}("");
        require(success, "Failed to send BNB");

        if (mappingBetInfos[msg.sender].amountTokens[whatsBet] == 0) {
            if (mappingBetInfos[msg.sender].earnWithdrawled[whatsBet] !=0) {
                revert("You have already withdrawn your winnings from your bet");
            }
            revert("You haven't placed any bets");
        }

        require(openBet[whatsBet] == false && resultFinalBet[whatsBet] != 0, "Out of time to bet");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 amountTokens = mappingBetInfos[msg.sender].amountTokens[whatsBet];
        uint256 whatsMyBetPool = mappingBetInfos[msg.sender].whatsMyBetPool[whatsBet];

        (uint256 getEarnOfBetReturn, uint256 getAmountFees,) = getEarnOfBet(msg.sender,whatsBet);

        //Both pools had stakes
        if (amountTokensOnFirstPoolBet[whatsBet] != 0 && amountTokensOnSecondPoolBet[whatsBet] != 0) {

            //Winner
            if (whatsMyBetPool == resultFinalBet[whatsBet]) {

                mappingBetInfos[msg.sender].amountTokens[whatsBet] = 0;
                mappingBetInfos[msg.sender].isBetter[whatsBet] = false;
                mappingBetInfos[msg.sender].isBetWinner[whatsBet] = true;
                mappingBetInfos[msg.sender].earnWithdrawled[whatsBet] = getEarnOfBetReturn;
                (mappingBetInfos[msg.sender].myAPR[whatsBet],) = estimateAPR(msg.sender,whatsBet);

                IERC20(addressDogeCUP).transfer(msg.sender, amountTokens); 
                IERC20(addressDogeCUP).transfer(msg.sender, getEarnOfBetReturn); 
                IERC20(addressDogeCUP).transfer(burnWallet, getAmountFees); 

                amountTokensInBet -= amountTokens;
                amountTokensClaimed += getEarnOfBetReturn;
                amountFeesTake += getAmountFees;

                emit betEarnClaimed(msg.sender,whatsBet, amountTokens, getEarnOfBetReturn);

            //draw
            } else if (resultFinalBet[whatsBet]  == 3) {
                mappingBetInfos[msg.sender].amountTokens[whatsBet] = 0;
                mappingBetInfos[msg.sender].isBetter[whatsBet] = false;
                mappingBetInfos[msg.sender].isBetWinner[whatsBet] = false;
                mappingBetInfos[msg.sender].earnWithdrawled[whatsBet] = 0;
                mappingBetInfos[msg.sender].myAPR[whatsBet] = 0;

                IERC20(addressDogeCUP).transfer(msg.sender, amountTokens); 

                amountTokensInBet -= amountTokens;

            //Loser
            } else {
                revert("You lost the bet");
            }

        //One of the pools had no bet
        //Tokens are returned to the bettor        
        } else if (
            amountTokensOnFirstPoolBet[whatsBet] == 0 ||
            amountTokensOnSecondPoolBet[whatsBet] == 0
            ) {
            mappingBetInfos[msg.sender].amountTokens[whatsBet] = 0;
            mappingBetInfos[msg.sender].isBetter[whatsBet] = false;
            mappingBetInfos[msg.sender].isBetWinner[whatsBet] = false;
            mappingBetInfos[msg.sender].earnWithdrawled[whatsBet] = 0;
            mappingBetInfos[msg.sender].myAPR[whatsBet] = 0;

            IERC20(addressDogeCUP).transfer(msg.sender, amountTokens); 

            amountTokensInBet -= amountTokens;
        }
    }

    function setOpenPoolBet() external onlyOwner {
        timeOpenBet = block.timestamp;
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function setAddresses (
        address _addressDogeCUP) 
        external onlyOwner {

        addressDogeCUP = _addressDogeCUP;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function removeBNB () public onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function managerERC20 (address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setMappingAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
    }

    function setMinimumForBet(uint256 _minimumForBet) external onlyOwner {
        minimumForBet = _minimumForBet;
    }

    function setFees (uint256 _feesProject, uint256 _feesNetwork) external onlyOwner {
        feesProject = _feesProject;
        feesNetwork = _feesNetwork;
    }


    function setCheckSecurityActived(bool boolean) external onlyOwner {
        checkSecurityActived = boolean;
    }

    function setDogeCUPAddressContract (address _addressDogeCUP) external onlyOwner {
        addressDogeCUP = _addressDogeCUP;
    }
    
}