/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: MIT

/*

    Texas Protocol - staking pool 
    https://texasprotocol.io/
    https://t.me/texasprotocol
    

    @dev    https://t.me/italo_blockchain
            https://github.com/italoHonoratoSA

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


interface IWrapperDaoTXS {
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

contract TexasStakingPool is Pausable, Ownable, ReentrancyGuard {

    using SafeMath for uint256;

    uint256 pool1months = 30 days;
    uint256 pool3months = 90 days;
    uint256 pool6months = 180 days;
   
    uint256 public amountTXSpool1months;
    uint256 public amountTXSpool3months;
    uint256 public amountTXSpool6months;

    uint256 public amountTXSclaimed1months;
    uint256 public amountTXSclaimed3months;
    uint256 public amountTXSclaimed6months;

    uint256 public totalStaking;
    uint256 public stakingOnPool1months;
    uint256 public stakingOnPool3months;
    uint256 public stakingOnPool6months;

    uint256 public stampDeployAddressThis;
    uint256 public timeOpenPoolStaking;
    bool public settedTimeOpenPoolStaking;
    uint256 public timeToWithdraw;
    bool public checkSecurityActived;

    address public   addressTexas =      0xCC14eB2829491c8f6840Df545d5CA2A7504DDc58;
    address public   addressDaoWrapper =   0x2F40A741670a4D796984dD10fa9E8fa49004C00e;
    address internal addressBUSD =    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal addressPCVS2 =   0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal addressWBNB =    0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public   burnWallet =     0x9834E25105435074a05f4f9427C5d6501E7378Cd;

    //Iterar variáveis em arrays é mais prático é uma melhor prática
    //Porém trabalhar com variáveis em struct custa menos gás do que iterar veriáveis em arrays
    //Por esse motivo optamos pelo ônus de criar armazenamento dessa forma para evitar gastos para o staker 
    struct staking1months {
        uint256 startStaking1;
        uint256 startStaking2;
        uint256 startStaking3;
        uint256 amountTokens1;
        uint256 amountTokens2;
        uint256 amountTokens3;
    }

    struct staking3months {
        uint256 startStaking1;
        uint256 startStaking2;
        uint256 startStaking3;
        uint256 amountTokens1;
        uint256 amountTokens2;
        uint256 amountTokens3;
    }    
    
    struct staking6months {
        uint256 startStaking1;
        uint256 startStaking2;
        uint256 startStaking3;
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

    address[] public allAddressStaking;
    uint256[] public allWhatsStakingPool;
    uint256[] public allWhatsNumberStaking;

    mapping(address => staking1months) mappingStaking1months;
    mapping(address => staking3months) mappingStaking3months;
    mapping(address => staking6months) mappingStaking6months;

    mapping(address => claim1months) mappingClaim1months;
    mapping(address => claim3months) mappingClaim3months;
    mapping(address => claim6months) mappingClaim6months;

    mapping(address => bool) public mappingAuth;

    event stakingEvent(
        address indexed addressStaking, 
        uint256 amountTXS, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStaking);

    event claimEvent(
        address indexed addressStaking, 
        uint256 amountTXS, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStaking);

    receive() external payable {}

    constructor() {
        stampDeployAddressThis = block.timestamp;
        checkSecurityActived = true;
        timeToWithdraw = 270 days;

        mappingAuth[_msgSender()] = true;
    }

    function getMappingAuth(address account) public view returns (bool){
        return mappingAuth[account]; 
    }

    function checkSecurity (address account) public view returns (bool checkSecurityReturn) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }

        if (!getMappingAuth(account)) {
            if (size == 0 && tx.origin == account) {
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
        uint256 whatsNumberStaking) 
        public view returns(
            uint256 startStaking,
            uint256 amountTokens,
            uint256 rewardsClaimed,
            uint256 timePassed,
            uint256 rewardPool) {

        if (whatsPoolStaking == 1) {
            timePassed = 30 * 24 * 60 * 60;
            rewardPool = 10;
            if (whatsNumberStaking == 1) {
                startStaking = mappingStaking1months[staker].startStaking1;
                amountTokens =  mappingStaking1months[staker].amountTokens1;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed1;
            } else if (whatsNumberStaking == 2) {
                startStaking = mappingStaking1months[staker].startStaking2;
                amountTokens =  mappingStaking1months[staker].amountTokens2;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed2;
            }  else if (whatsNumberStaking == 3) {
                startStaking = mappingStaking1months[staker].startStaking3;
                amountTokens =  mappingStaking1months[staker].amountTokens3;
                rewardsClaimed = mappingClaim1months[staker].rewardsClaimed3;
            }
        } else if (whatsPoolStaking == 2) {
            timePassed = 90 * 24 * 60 * 60;
            rewardPool = 15;
            if (whatsNumberStaking == 1) {
                startStaking = mappingStaking3months[staker].startStaking1;
                amountTokens =  mappingStaking3months[staker].amountTokens1;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed1;
            } else if (whatsNumberStaking == 2) {
                startStaking = mappingStaking3months[staker].startStaking2;
                amountTokens =  mappingStaking3months[staker].amountTokens2;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed2;
            }  else if (whatsNumberStaking == 3) {
                startStaking = mappingStaking3months[staker].startStaking3;
                amountTokens =  mappingStaking3months[staker].amountTokens3;
                rewardsClaimed = mappingClaim3months[staker].rewardsClaimed3;
            }
        } else if (whatsPoolStaking == 3) {
            timePassed = 180 * 24 * 60 * 60;
            rewardPool = 20;
            if (whatsNumberStaking == 1) {
                startStaking = mappingStaking6months[staker].startStaking1;
                amountTokens =  mappingStaking6months[staker].amountTokens1;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed1;
            } else if (whatsNumberStaking == 2) {
                startStaking = mappingStaking6months[staker].startStaking2;
                amountTokens =  mappingStaking6months[staker].amountTokens2;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed2;
            }  else if (whatsNumberStaking == 3) {
                startStaking = mappingStaking6months[staker].startStaking3;
                amountTokens =  mappingStaking6months[staker].amountTokens3;
                rewardsClaimed = mappingClaim6months[staker].rewardsClaimed3;
            }
        }
        return (startStaking,amountTokens,rewardsClaimed,timePassed,rewardPool);
    }

    function price(uint256 amountIn) public view returns (uint256) {

        uint256 priceReturn;
        if (amountIn != 0) {
            address[] memory path = new address[](3);
            path[0] = addressTexas;
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
            amountTXSpool1months + amountTXSpool3months + amountTXSpool6months;
        } 
        else if (whatsPoolStaking == 1) {liquidityTokensLocked = amountTXSpool1months;} 
        else if (whatsPoolStaking == 2) {liquidityTokensLocked = amountTXSpool3months;} 
        else if (whatsPoolStaking == 3) {liquidityTokensLocked = amountTXSpool6months;}

        liquidityTokensLockedUSD = price(liquidityTokensLocked);

        return (liquidityTokensLocked,liquidityTokensLockedUSD);
    }


    function getUnpaidEarning(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStaking) 
        public 
        view 
        returns 
        (uint256 amountRewardClaim) {

        uint256 startStaking;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStaking,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStaking);

        amountRewardClaim = amountTokens.mul(rewardPool).div(100);  

        if (block.timestamp < startStaking + timePassed) {
            amountRewardClaim = 
            (block.timestamp - startStaking).mul(amountRewardClaim).div(timePassed);  
        }

        if (amountRewardClaim <= rewardsClaimed) return 0;
        amountRewardClaim = amountRewardClaim - rewardsClaimed;

        return amountRewardClaim;  
    }

    function getFeesToCancel(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStaking) 
        public 
        view 
        returns 
        (uint256 feesToCancel) {

        uint256 startStaking;

        (startStaking,,,,) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStaking);

        if (whatsPoolStaking == 1) {
            if (block.timestamp < startStaking + pool1months) {
                feesToCancel = 15;  
            }
        } else if (whatsPoolStaking == 2) {
            if (block.timestamp < startStaking + pool3months) {
                feesToCancel = 30;  
            }        
        } else if (whatsPoolStaking == 3) {
            if (block.timestamp < startStaking + pool6months) {
                feesToCancel = 45;  
            }
        }

    }

    function getFeesWithdraw(
        address staker, 
        uint256 whatsPoolStaking,
        uint256 whatsNumberStaking) 
        public 
        view 
        returns 
        (uint256 feesWithdraw) {

        uint256 startStaking;

        (startStaking,,,,) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStaking);

        if (block.timestamp < startStaking + 7 days) {
            feesWithdraw = 10;  
        } else if (block.timestamp < startStaking + 15 days) {
            feesWithdraw = 5;  

        //@devs Os devs sabem que isso é redundância
        //Apenas serve para seguir o padrão de demonstrar a taxas
        }  else if (block.timestamp < startStaking + 30 days) {
            feesWithdraw = 0;  
        } 
    }


    function stakingTXS(
        address staker, 
        uint256 amountTXStokens, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStaking)
        external 
        whenNotPaused 
        nonReentrant() {

        require(timeOpenPoolStaking != 0, "The staking pools are not yet open");
        require(staker == _msgSender(), "Not approved");
        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStaking <= 3 && whatsNumberStaking != 0, "Invalid staking number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        IERC20(addressTexas).transferFrom(staker, address(this), amountTXStokens);
        IWrapperDaoTXS(addressDaoWrapper).depositFor_AdressProject(staker,amountTXStokens);

        if (whatsPoolStaking == 1) {
            amountTXSpool1months += amountTXStokens;
            stakingOnPool1months ++;

            if (whatsNumberStaking == 1) {
                require(mappingStaking1months[staker].amountTokens1 == 0, "This staking has already been held");
                mappingStaking1months[staker].startStaking1 = block.timestamp;
                mappingStaking1months[staker].amountTokens1 = amountTXStokens;
                mappingClaim1months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStaking == 2) {
                require(mappingStaking1months[staker].amountTokens2 == 0, "This staking has already been held");
                mappingStaking1months[staker].startStaking2 = block.timestamp;
                mappingStaking1months[staker].amountTokens2 = amountTXStokens;
                mappingClaim1months[staker].rewardsClaimed2 = 0;
            } else if (whatsNumberStaking == 3) {
                require(mappingStaking1months[staker].amountTokens3 == 0, "This staking has already been held");
                mappingStaking1months[staker].startStaking3 = block.timestamp;
                mappingStaking1months[staker].amountTokens3 = amountTXStokens;
                mappingClaim1months[staker].rewardsClaimed3 = 0;
            }
        } else if (whatsPoolStaking == 2) {
            amountTXSpool3months += amountTXStokens;
            stakingOnPool3months ++;
            
            if (whatsNumberStaking == 1) {
                require(mappingStaking3months[staker].amountTokens1 == 0, "This staking has already been held");
                mappingStaking3months[staker].startStaking1 = block.timestamp;
                mappingStaking3months[staker].amountTokens1 = amountTXStokens;
                mappingClaim3months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStaking == 2) {
                require(mappingStaking3months[staker].amountTokens2 == 0, "This staking has already been held");
                mappingStaking3months[staker].startStaking2 = block.timestamp;
                mappingStaking3months[staker].amountTokens2 = amountTXStokens;
                mappingClaim3months[staker].rewardsClaimed2 = 0;
            } else if (whatsNumberStaking == 3) {
                require(mappingStaking3months[staker].amountTokens3 == 0, "This staking has already been held");
                mappingStaking3months[staker].startStaking3 = block.timestamp;
                mappingStaking3months[staker].amountTokens3 = amountTXStokens;
                mappingClaim3months[staker].rewardsClaimed3 = 0;
            }
        } else if (whatsPoolStaking == 3) {
            amountTXSpool6months += amountTXStokens;
            stakingOnPool6months ++;

            if (whatsNumberStaking == 1) {
                require(mappingStaking6months[staker].amountTokens1 == 0, "This staking has already been held");
                mappingStaking6months[staker].startStaking1 = block.timestamp;
                mappingStaking6months[staker].amountTokens1 = amountTXStokens;
                mappingClaim6months[staker].rewardsClaimed1 = 0;
            } else if (whatsNumberStaking == 2) {
                require(mappingStaking6months[staker].amountTokens2 == 0, "This staking has already been held");
                mappingStaking6months[staker].startStaking2 = block.timestamp;
                mappingStaking6months[staker].amountTokens2 = amountTXStokens;
                mappingClaim6months[staker].rewardsClaimed2 = 0;
            } else if (whatsNumberStaking == 3) {
                require(mappingStaking6months[staker].amountTokens3 == 0, "This staking has already been held");
                mappingStaking6months[staker].startStaking3 = block.timestamp;
                mappingStaking6months[staker].amountTokens3 = amountTXStokens;
                mappingClaim6months[staker].rewardsClaimed3 = 0;
            }
        }
        totalStaking ++;
        allAddressStaking.push(staker);
        allWhatsStakingPool.push(whatsPoolStaking);
        allWhatsNumberStaking.push(whatsNumberStaking);

        emit stakingEvent(
            staker, 
            amountTXStokens, 
            whatsPoolStaking, 
            whatsNumberStaking);
    }    

    function claimStaking(
        address staker, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStaking) 
        public 
        whenNotPaused() 
        nonReentrant() {

        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStaking <= 3 && whatsNumberStaking != 0, "Invalid staking number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 startStaking;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStaking,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStaking);
        require(0 < amountTokens, "No staking to claim");

        uint256 unpaidEarnings = getUnpaidEarning(staker,whatsPoolStaking,whatsNumberStaking);
        uint256 feesWithdraw = getFeesWithdraw(staker,whatsPoolStaking,whatsNumberStaking);
        uint256 feesToCancel = getFeesToCancel(staker,whatsPoolStaking,whatsNumberStaking);

        if (whatsPoolStaking == 1) {
            amountTXSpool1months -= amountTokens;
            stakingOnPool1months --;
            if      (whatsNumberStaking == 1) {mappingStaking1months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStaking == 2) {mappingStaking1months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStaking == 3) {mappingStaking1months[staker].amountTokens3 = 0;}

        } else if (whatsPoolStaking == 2) {
            amountTXSpool3months -= amountTokens;
            stakingOnPool3months --;
            if      (whatsNumberStaking == 1) {mappingStaking3months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStaking == 2) {mappingStaking3months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStaking == 3) {mappingStaking3months[staker].amountTokens3 = 0;}

        } else if (whatsPoolStaking == 3) {
            amountTXSpool6months -= amountTokens;
            stakingOnPool6months --;
            if      (whatsNumberStaking == 1) {mappingStaking6months[staker].amountTokens1 = 0;} 
            else if (whatsNumberStaking == 2) {mappingStaking6months[staker].amountTokens2 = 0;} 
            else if (whatsNumberStaking == 3) {mappingStaking6months[staker].amountTokens3 = 0;}

        }

        IERC20(addressTexas).transfer(staker, amountTokens);
        IERC20(addressTexas).transfer(staker, unpaidEarnings * (100 - feesWithdraw - feesToCancel) / 100);
        IERC20(addressTexas).transfer(burnWallet, unpaidEarnings * feesWithdraw / 100);
        IERC20(addressTexas).transfer(burnWallet, unpaidEarnings * feesToCancel / 100);

        IWrapperDaoTXS(addressDaoWrapper).withdrawTo_AdressProject(staker,amountTokens);

        if (whatsPoolStaking == 1) {
            amountTXSclaimed1months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim1months[staker].rewardsClaimed1 += unpaidEarnings;
           } else if (whatsNumberStaking == 2) {
                mappingClaim1months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim1months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 2) {
            amountTXSclaimed3months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim3months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStaking == 2) {
                mappingClaim3months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim3months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 3) {
            amountTXSclaimed6months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim6months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStaking == 2) {
                mappingClaim6months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim6months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        }
        totalStaking --;
        
        emit claimEvent(
            staker,
            amountTokens,
            whatsPoolStaking,
            whatsNumberStaking);
    }

    function claimRewards(
        address staker, 
        uint256 whatsPoolStaking, 
        uint256 whatsNumberStaking) 
        public 
        whenNotPaused() 
        nonReentrant() {

        require(whatsPoolStaking <= 3 && whatsPoolStaking != 0, "Staking Pool invalidates");
        require(whatsNumberStaking <= 3 && whatsNumberStaking != 0, "Invalid staking number");

        if (checkSecurityActived) {
            require(checkSecurity(_msgSender()), "Security check not passed!");
        }

        uint256 startStaking;
        uint256 amountTokens;
        uint256 rewardsClaimed;
        uint256 timePassed;
        uint256 rewardPool;

        (startStaking,amountTokens,rewardsClaimed,timePassed,rewardPool) = 
        getInfos(staker,whatsPoolStaking,whatsNumberStaking);
        require(0 < amountTokens, "No staking to claim");

        uint256 unpaidEarnings = getUnpaidEarning(staker,whatsPoolStaking,whatsNumberStaking);
        uint256 feesWithdraw = getFeesWithdraw(staker,whatsPoolStaking,whatsNumberStaking);

        IERC20(addressTexas).transfer(staker, unpaidEarnings * (100 - feesWithdraw) / 100);
        IERC20(addressTexas).transfer(burnWallet, unpaidEarnings * feesWithdraw / 100);

        if (whatsPoolStaking == 1) {
            amountTXSclaimed1months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim1months[staker].rewardsClaimed1 += unpaidEarnings;
           } else if (whatsNumberStaking == 2) {
                mappingClaim1months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim1months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 2) {
            amountTXSclaimed3months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim3months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStaking == 2) {
                mappingClaim3months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim3months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        } else if (whatsPoolStaking == 3) {
            amountTXSclaimed6months += unpaidEarnings;
            if (whatsNumberStaking == 1) {
                mappingClaim6months[staker].rewardsClaimed1 += unpaidEarnings;
            } else if (whatsNumberStaking == 2) {
                mappingClaim6months[staker].rewardsClaimed2 += unpaidEarnings;
            } else if (whatsNumberStaking == 3) {
                mappingClaim6months[staker].rewardsClaimed3 += unpaidEarnings;
            }
        }

        emit claimEvent(
            staker,
            amountTokens,
            whatsPoolStaking,
            whatsNumberStaking);
    }


    function setOpenPoolStaking() external onlyOwner {
        require(settedTimeOpenPoolStaking == false);
        settedTimeOpenPoolStaking = true;
        timeOpenPoolStaking = block.timestamp;
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function setTexasToken (address _addressTexas) external onlyOwner {
        addressTexas = _addressTexas;
    }

    function setAddressDaoWrapper (address _addressDaoWrapper) external onlyOwner {
        addressDaoWrapper = _addressDaoWrapper;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function recuver(address token) external onlyOwner {
        if (token == addressTexas) {
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