/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

/*
███████╗██╗██╗     ████████╗███████╗██████╗ ███████╗██╗    ██╗ █████╗ ██████╗     ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗███████╗██████╗ 
██╔════╝██║██║     ╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║    ██║██╔══██╗██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝██╔════╝██╔══██╗
█████╗  ██║██║        ██║   █████╗  ██████╔╝███████╗██║ █╗ ██║███████║██████╔╝    ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ █████╗  ██████╔╝
██╔══╝  ██║██║        ██║   ██╔══╝  ██╔══██╗╚════██║██║███╗██║██╔══██║██╔═══╝     ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ██╔══╝  ██╔══██╗
██║     ██║███████╗   ██║   ███████╗██║  ██║███████║╚███╔███╔╝██║  ██║██║         ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ███████╗██║  ██║
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝         ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                                                                                                                    
SPDX-License-Identifier: UNLICENSED
*/

pragma solidity ^0.8;

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
}

interface IFilterRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        uint liquidityLockTime
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        uint liquidityLockTime
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function setVerifiedSafe(address tokenAddr) external;
}

interface IFilterFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDeployedToken {
    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, uint[] memory _tokenArgs) external;
    function initializePair(address _pairAddress) external;
}

contract FilterDeployer {
    address public wethAddr;
    address public factoryAddr;
    address public routerAddr;
    address public owner;

    address[] public tokenTemplateAddresses;

    /*
        BasicToken: 0x0
        DeflationaryToken: 0x0
        LiquidityGeneratorToken: 0x0
    */

    constructor(address _wethAddr, address _factoryAddr, address _routerAddr) {
        wethAddr = _wethAddr;
        factoryAddr = _factoryAddr;
        routerAddr = _routerAddr;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    uint maxOwnerShare = 25;

    function getCode(address _codeAddress) public view returns (bytes memory templateCode) {
        return _codeAddress.code;
    }

    function cloneContract(address addressToClone) public returns (address) {
        address deployedAddress;
        assembly {
            mstore(0x0, or (0x5880730000000000000000000000000000000000000000803b80938091923cF3, mul(addressToClone, 0x1000000000000000000)))
            deployedAddress := create(0, 0, 32)
        }
        return deployedAddress;
    }


    /*
        MOST BASIC TEMPLATE:
        string memory _name, 
        string memory _symbol, 
        address _owner, 
        address _tokenDeployer,
        uint[] memory _tokenArgs:
            uint _totalSupply 


        BasicToken:
        string memory _name, 
        string memory _symbol, 
        address _owner, 
        address _tokenDeployer
        uint[] memory _tokenArgs:
            uint _totalSupply


        LiquidityGeneratorToken:
        string memory _name, 
        string memory _symbol, 
        uint _totalSupply, 
        address _owner, 
        address _tokenDeployer,
        uint[] memory _tokenArgs:
            uint _totalSupply,
            uint _taxFee,
            uint _liquidityFee,     
            uint _maxTxAmount,
            uint _minSwapAndLiquifyTriggerAmount,
            uint _maxAllowableTaxFee,
            uint _maxAllowableLiquidityFee,
            uint _minAllowableMaxTxPercent
  

    */
    function createTokenWithETH(
        uint tokenType,
        string memory tokenName,
        string memory tokenSymbol,
        uint[] memory tokenArgs,
        uint ownerShare,
        uint deadline,
        uint liquidityLockTime
    ) public payable {
        //do checks
        require(ownerShare <= maxOwnerShare, "FilterDeployer: DEV_SHARE_TOO_HIGH");
        require(tokenType < tokenTemplateAddresses.length, "FilterDeployer: INVALID_TOKEN_TYPE");
        require(msg.value > 0, "FilterDeployer: NO_ETH_SUPPLIED");

        //deploy raw contract from template
        address deployedTokenAddr = cloneContract(tokenTemplateAddresses[tokenType]);

        //token now created: this contract (deployer) now has all the tokens
        IDeployedToken(deployedTokenAddr).initializeToken(tokenName, tokenSymbol, msg.sender, address(this), tokenArgs);

        //initialize token parameters

        //give owner his share of tokens
        IERC20 deployedToken = IERC20(deployedTokenAddr);
        deployedToken.transfer(msg.sender, ((deployedToken.balanceOf(address(this)) * ownerShare) / 100));

        //now add liquidity, and transfer tokens from this contract (deployer) to FilterPair

        IFilterRouter(routerAddr).addLiquidityETH{value: msg.value}(
            deployedTokenAddr,
            IERC20(deployedTokenAddr).balanceOf(address(this)),
            0,
            0,
            msg.sender,
            deadline,
            liquidityLockTime
        );

        //check if pair needs initialized, and if so then initialize pair

        address pairAddr = IFilterFactory(factoryAddr).getPair(wethAddr, deployedTokenAddr);
        IDeployedToken(deployedTokenAddr).initializePair(pairAddr);             

        //everything else is done, is confirmed safe so set as verified safe

        IFilterRouter(routerAddr).setVerifiedSafe(deployedTokenAddr);
    }


    //NEXT: do alt pair token creation

    // **** ADMIN ONLY FUNCTIONS ****

    function addTokenTemplate(address _templateAddress) public onlyOwner {
        tokenTemplateAddresses.push(_templateAddress);
    }

    //do function to change a specific token template
}