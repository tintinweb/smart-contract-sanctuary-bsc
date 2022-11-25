/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT

/*

    https://app.dogecup.com/
    https://dogecup.com/
    https://t.me/dogecupofficial
    https://t.me/dogecupnews


*/

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


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


interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

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

contract DCUPStakingPool is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 pool1months = 30 days;
    uint256 pool3months = 90 days;
    uint256 pool6months = 180 days;
   
    uint256 public amountDCUPpool1months;
    uint256 public amountDCUPpool3months;
    uint256 public amountDCUPpool6months;

    uint256 public amountDCUPclaimed1months;
    uint256 public amountDCUPclaimed3months;
    uint256 public amountDCUPclaimed6months;

    uint256 public totalStake;

    uint256 public stampDeployAddressThis;
    uint256 public timeOpenPoolsStake;
    uint256 public timeToWithdraw;
    bool public checkSecurityActived;

    address public   addressDogeCUP =      0xcEf365B5932558c7E3212053f99634F3D9e078bA;
    address public   addressDaoWrapper =   0x30e408fbA789d384003e436ccFEA14811571dDD9;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   burnWallet =     0xFa9ed83e12b651c987DF7201A4A4f6ee8B1185D7;

    struct staking1months {
        uint256 startStake1;
        uint256 startStake2;
        uint256 startStake3;
        uint256 amountTokens1;
        uint256 amountTokens2;
        uint256 amountTokens3;
    }

    struct staking3months {
        uint256 startStake1;
        uint256 startStake2;
        uint256 startStake3;
        uint256 amountTokens1;
        uint256 amountTokens2;
        uint256 amountTokens3;
    }    
    
    struct staking6months {
        uint256 startStake1;
        uint256 startStake2;
        uint256 startStake3;
        uint256 amountTokens1;
        uint256 amountTokens2;
        uint256 amountTokens3;
    }

    struct claim1months {
        uint256 rewardsClaimed1;
        uint256 rewardsClaimed2;
        uint256 rewardsClaimed3;
    }

    struct claim3months {
        uint256 rewardsClaimed1;
        uint256 rewardsClaimed2;
        uint256 rewardsClaimed3;
    }

    struct claim6months {
        uint256 rewardsClaimed1;
        uint256 rewardsClaimed2;
        uint256 rewardsClaimed3;
    }

    address[] public allAddressStaker;
    uint256[] public allWhatsStakingPool;
    uint256[] public allWhatsNumberStaking;

    mapping(address => staking1months) mappingStaking1months;
    mapping(address => staking3months) mappingStaking3months;
    mapping(address => staking6months) mappingStaking6months;

    mapping(address => claim1months) mappingClaim1months;
    mapping(address => claim3months) mappingClaim3months;
    mapping(address => claim6months) mappingClaim6months;

    mapping(address => bool) private mappingAuth;

    event staking(
        address indexed addressStaker, 
        uint256 amountDCUP, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake);

    event claimed(
        address indexed addressStaker, 
        uint256 amountDCUP, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake);

    receive() external payable {}

    constructor() {
        stampDeployAddressThis = block.timestamp;
        checkSecurityActived = true;
        timeToWithdraw = 180 days;
    }

    function getMappingAuth(address account) public view returns (bool){
        return mappingAuth[account]; 
    }

    function checkSecurity (address account) public view returns (bool checkSecurityReturn) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        if (account != owner() || !mappingAuth[account]) {
            if (size == 0 && tx.origin == msg.sender) {
                checkSecurityReturn = true;
            } else {
                require(false,"Verificacao de seguranca nao aprovada");
            }
        } else {
            checkSecurityReturn = true;
        }
        return checkSecurityReturn;
    }

    function getInfos(
        address staker, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake) 
        public view returns(
            uint256 startStake,
            uint256 amountTokens,
            uint256 rewardsClaimed,
            uint256 timePassed,
            uint256 rewardPool) {

        if (whatsPoolStaking == 1) {
            timePassed = 30 * 24 * 60 * 60;
            rewardPool = 25;
            if (whatsNumberStake == 1) {
                startStake = mappingStaking1months[staker].startStake1;
                amountTokens =  mappingStaking1months[staker].amountTokens1;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed1;
            } else if (whatsNumberStake == 2) {
                startStake = mappingStaking1months[staker].startStake2;
                amountTokens =  mappingStaking1months[staker].amountTokens2;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed2;
            }  else if (whatsNumberStake == 3) {
                startStake = mappingStaking1months[staker].startStake3;
                amountTokens =  mappingStaking1months[staker].amountTokens3;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed3;
            }
        } else if (whatsPoolStaking == 2) {
            timePassed = 90 * 24 * 60 * 60;
            rewardPool = 40;
            if (whatsNumberStake == 1) {
                startStake = mappingStaking3months[staker].startStake1;
                amountTokens =  mappingStaking3months[staker].amountTokens1;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed1;
            } else if (whatsNumberStake == 2) {
                startStake = mappingStaking3months[staker].startStake2;
                amountTokens =  mappingStaking3months[staker].amountTokens2;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed2;
            }  else if (whatsNumberStake == 3) {
                startStake = mappingStaking3months[staker].startStake3;
                amountTokens =  mappingStaking3months[staker].amountTokens3;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed3;
            }
        } else if (whatsPoolStaking == 3) {
            timePassed = 180 * 24 * 60 * 60;
            rewardPool = 55;
            if (whatsNumberStake == 1) {
                startStake = mappingStaking6months[staker].startStake1;
                amountTokens =  mappingStaking6months[staker].amountTokens1;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed1;
            } else if (whatsNumberStake == 2) {
                startStake = mappingStaking6months[staker].startStake2;
                amountTokens =  mappingStaking6months[staker].amountTokens2;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed2;
            }  else if (whatsNumberStake == 3) {
                startStake = mappingStaking6months[staker].startStake3;
                amountTokens =  mappingStaking6months[staker].amountTokens3;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed3;
            }
        }
        return (startStake,amountTokens,rewardsClaimed,timePassed,rewardPool);
    }

    function price(uint256 amountIn) public view returns (uint256) {

        uint256 priceReturn;
        if (amountIn != 0) {
            address[] memory path = new address[](3);
            path[0] = addressDogeCUP;
            path[1] = addressWBNB;
            path[2] = addressBUSD;

            uint256[] memory amountOutMins = IUniswapV2Router(addressPCVS2)
            .getAmountsOut(amountIn, path);
            priceReturn = amountOutMins[path.length -1];
        }
        return priceReturn;
    } 


    //Total Value Locked
    function TVL (uint256 whatsPoolStaking) public view returns (uint256,uint256) {

        uint256 liquidityTokensLocked;
        uint256 liquidityTokensLockedUSD;
        if (whatsPoolStaking == 0) {
            liquidityTokensLocked = 
            amountDCUPpool1months + amountDCUPpool3months + amountDCUPpool6months;
        } 
        else if (whatsPoolStaking == 1) {liquidityTokensLocked = amountDCUPpool1months;} 
        else if (whatsPoolStaking == 2) {liquidityTokensLocked = amountDCUPpool3months;} 
        else if (whatsPoolStaking == 3) {liquidityTokensLocked = amountDCUPpool6months;}

        liquidityTokensLockedUSD = price(liquidityTokensLocked);

        return (liquidityTokensLocked,liquidityTokensLockedUSD);
    }


    function getUnpaidEarning(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStake) 
        public 
        view 
        returns 
        (uint256 amountRewardClaim) {

        uint256 startStake;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStake,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStake);

        amountRewardClaim = amountTokens.mul(rewardPool).div(100);  

        if (block.timestamp < startStake + timePassed) {
            amountRewardClaim = 
            ((block.timestamp - startStake).mul(amountRewardClaim).div(timePassed));  
        }

        if (amountRewardClaim <= rewardsClaimed) return 0;
        amountRewardClaim = amountRewardClaim - rewardsClaimed;

        return amountRewardClaim;  
    }

    function getFeesToCancel(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStake) 
        public 
        view 
        returns 
        (uint256 feesToCancel) {

        uint256 startStake;

        (startStake,,,,) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStake);

        if (whatsPoolStaking == 1) {
            if (block.timestamp < startStake + pool1months) {
                feesToCancel = 15;  
            }
        } else if (whatsPoolStaking == 2) {
            if (block.timestamp < startStake + pool3months) {
                feesToCancel = 30;  
            }        
        } else if (whatsPoolStaking == 3) {
            if (block.timestamp < startStake + pool6months) {
                feesToCancel = 45;  
            }
        }

    }

    function getFeesWithdraw(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStake) 
        public 
        view 
        returns 
        (uint256 feesWithdraw) {

        uint256 startStake;

        (startStake,,,,) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStake);

        if (block.timestamp < startStake + 7 days) {
            feesWithdraw = 10;  
        } else if (block.timestamp < startStake + 15 days) {
            feesWithdraw = 5;  
        }  else if (block.timestamp < startStake + 30 days) {
            feesWithdraw = 0;  
        } 
    }


    function stake(
        address staker, 
        uint256 amountDCUPtokens, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake)

        external 
        whenNotPaused 
        nonReentrant() {

        require(timeOpenPoolsStake != 0, "The stake pools are not yet open");
        require(staker == _msgSender(), "Not approved");
        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStake <= 3 && whatsNumberStake != 0, "Invalid stake number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        IERC20(addressDogeCUP).transferFrom(staker, address(this), amountDCUPtokens);
        IWrapperDaoDCUP(addressDaoWrapper).depositFor_AdressProject(staker,amountDCUPtokens);

        if (whatsPoolStaking == 1) {
            amountDCUPpool1months += amountDCUPtokens;
            if (whatsNumberStake == 1) {
                require(mappingStaking1months[staker].amountTokens1 == 0, "This stake has already been held");
                mappingStaking1months[staker].startStake1 = block.timestamp;
                mappingStaking1months[staker].amountTokens1 = amountDCUPtokens;
                mappingClaim1months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStake == 2) {
                require(mappingStaking1months[staker].amountTokens2 == 0, "This stake has already been held");
                mappingStaking1months[staker].startStake2 = block.timestamp;
                mappingStaking1months[staker].amountTokens2 = amountDCUPtokens;
                mappingClaim1months[staker].rewardsClaimed2 = 0;
            } else if(whatsNumberStake == 3) {
                require(mappingStaking1months[staker].amountTokens3 == 0, "This stake has already been held");
                mappingStaking1months[staker].startStake3 = block.timestamp;
                mappingStaking1months[staker].amountTokens3 = amountDCUPtokens;
                mappingClaim1months[staker].rewardsClaimed3 = 0;
            }
        } else if (whatsPoolStaking == 2) {
            amountDCUPpool3months += amountDCUPtokens;
            if (whatsNumberStake == 1) {
                require(mappingStaking3months[staker].amountTokens1 == 0, "This stake has already been held");
                mappingStaking3months[staker].startStake1 = block.timestamp;
                mappingStaking3months[staker].amountTokens1 = amountDCUPtokens;
                mappingClaim3months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStake == 2) {
                require(mappingStaking3months[staker].amountTokens2 == 0, "This stake has already been held");
                mappingStaking3months[staker].startStake2 = block.timestamp;
                mappingStaking3months[staker].amountTokens2 = amountDCUPtokens;
                mappingClaim3months[staker].rewardsClaimed2 = 0;
            } else if(whatsNumberStake == 3) {
                require(mappingStaking3months[staker].amountTokens3 == 0, "This stake has already been held");
                mappingStaking3months[staker].startStake3 = block.timestamp;
                mappingStaking3months[staker].amountTokens3 = amountDCUPtokens;
                mappingClaim3months[staker].rewardsClaimed3 = 0;
            }
        } else if (whatsPoolStaking == 3) {
            amountDCUPpool6months += amountDCUPtokens;
            if (whatsNumberStake == 1) {
                require(mappingStaking6months[staker].amountTokens1 == 0, "This stake has already been held");
                mappingStaking6months[staker].startStake1 = block.timestamp;
                mappingStaking6months[staker].amountTokens1 = amountDCUPtokens;
                mappingClaim6months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStake == 2) {
                require(mappingStaking6months[staker].amountTokens2 == 0, "This stake has already been held");
                mappingStaking6months[staker].startStake2 = block.timestamp;
                mappingStaking6months[staker].amountTokens2 = amountDCUPtokens;
                mappingClaim6months[staker].rewardsClaimed2 = 0;
            } else if(whatsNumberStake == 3) {
                require(mappingStaking6months[staker].amountTokens3 == 0, "This stake has already been held");
                mappingStaking6months[staker].startStake3 = block.timestamp;
                mappingStaking6months[staker].amountTokens3 = amountDCUPtokens;
                mappingClaim6months[staker].rewardsClaimed3 = 0;
            }
        }
        totalStake ++;
        allAddressStaker.push(staker);
        allWhatsStakingPool.push(whatsPoolStaking);
        allWhatsNumberStaking.push(whatsNumberStake);

        emit staking(
            staker, 
            amountDCUPtokens, 
            whatsPoolStaking, 
            whatsNumberStake);
    }    


    function claimRewardsAndTokens(
        address staker, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake) 
        public 
        whenNotPaused() 
        nonReentrant() {

        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStake <= 3 && whatsNumberStake != 0, "Invalid stake number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 startStake;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStake,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStake);
        require(0 < amountTokens, "No stake to claim");

        uint256 unpaidEarnings = getUnpaidEarning(staker,whatsPoolStaking,whatsNumberStake);
        uint256 feesWithdraw = getFeesWithdraw(staker,whatsPoolStaking,whatsNumberStake);
        uint256 feesToCancel = getFeesToCancel(staker,whatsPoolStaking,whatsNumberStake);

        if (whatsPoolStaking == 1) {
            amountDCUPpool1months -= amountTokens;
            if      (whatsNumberStake == 1) {mappingStaking1months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStake == 2) {mappingStaking1months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStake == 3) {mappingStaking1months[staker].amountTokens3 = 0;}

        } else if (whatsPoolStaking == 2) {
            amountDCUPpool3months -= amountTokens;
            if      (whatsNumberStake == 1) {mappingStaking3months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStake == 2) {mappingStaking3months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStake == 3) {mappingStaking3months[staker].amountTokens3 = 0;}

        } else if (whatsPoolStaking == 3) {
            amountDCUPpool6months -= amountTokens;
            if      (whatsNumberStake == 1) {mappingStaking6months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStake == 2) {mappingStaking6months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStake == 3) {mappingStaking6months[staker].amountTokens3 = 0;}

        }

        IERC20(addressDogeCUP).transfer(staker, amountTokens);
        IERC20(addressDogeCUP).transfer(staker, unpaidEarnings * (100 - feesWithdraw - feesToCancel) / 100);
        IERC20(addressDogeCUP).transfer(burnWallet, unpaidEarnings * feesWithdraw / 100);
        IERC20(addressDogeCUP).transfer(burnWallet, unpaidEarnings * feesToCancel / 100);

        IWrapperDaoDCUP(addressDaoWrapper).withdrawTo_AdressProject(staker,amountTokens);

        if (whatsPoolStaking == 1) {
            amountDCUPclaimed1months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim1months[staker].rewardsClaimed1 += unpaidEarnings;
           } else if (whatsNumberStake == 2) {
                mappingClaim1months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim1months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 2) {
            amountDCUPclaimed3months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim3months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStake == 2) {
                mappingClaim3months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim3months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 3) {
            amountDCUPclaimed6months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim6months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStake == 2) {
                mappingClaim6months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim6months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        }

        totalStake --;
        
        emit claimed(
            staker,
            amountTokens,
            whatsPoolStaking,
            whatsNumberStake);
    }

    function claim(
        address staker, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStake) 
        public 
        whenNotPaused() 
        nonReentrant() {

        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStake <= 3 && whatsNumberStake != 0, "Invalid stake number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 startStake;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStake,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStake);
        require(0 < amountTokens, "No stake to claim");

        uint256 unpaidEarnings = getUnpaidEarning(staker,whatsPoolStaking,whatsNumberStake);
        uint256 feesWithdraw = getFeesWithdraw(staker,whatsPoolStaking,whatsNumberStake);

        IERC20(addressDogeCUP).transfer(staker, unpaidEarnings * (100 - feesWithdraw) / 100);
        IERC20(addressDogeCUP).transfer(burnWallet, unpaidEarnings * feesWithdraw / 100);

        if (whatsPoolStaking == 1) {
            amountDCUPclaimed1months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim1months[staker].rewardsClaimed1 += unpaidEarnings;
           } else if (whatsNumberStake == 2) {
                mappingClaim1months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim1months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 2) {
            amountDCUPclaimed3months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim3months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStake == 2) {
                mappingClaim3months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim3months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 3) {
            amountDCUPclaimed6months += unpaidEarnings;
            if (whatsNumberStake == 1) {
                mappingClaim6months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStake == 2) {
                mappingClaim6months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if(whatsNumberStake == 3) {
                mappingClaim6months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        }

        emit claimed(
            staker,
            amountTokens,
            whatsPoolStaking,
            whatsNumberStake);
    }


    function setOpenPoolStake() external onlyOwner {
        timeOpenPoolsStake = block.timestamp;
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function setDogeCUPAddressContract (address _addressDogeCUP, address _addressDaoWrapper) external onlyOwner {
        addressDogeCUP = _addressDogeCUP;
        addressDaoWrapper = _addressDaoWrapper;
    }
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function recuver(address token) external onlyOwner {
        if (token == addressDogeCUP) {
            require(stampDeployAddressThis + timeToWithdraw < block.timestamp);
        }
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function recuver() public onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

    function setAuth(address account, bool boolean) external onlyOwner {
        mappingAuth[account] = boolean;
    }

    function setCheckSecurityActived(bool boolean) external onlyOwner {
        checkSecurityActived = boolean;
    }

}