/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/*
███████╗██╗██╗     ████████╗███████╗██████╗ ███████╗██╗    ██╗ █████╗ ██████╗     ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗███████╗██████╗ 
██╔════╝██║██║     ╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║    ██║██╔══██╗██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝██╔════╝██╔══██╗
█████╗  ██║██║        ██║   █████╗  ██████╔╝███████╗██║ █╗ ██║███████║██████╔╝    ██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝ █████╗  ██████╔╝
██╔══╝  ██║██║        ██║   ██╔══╝  ██╔══██╗╚════██║██║███╗██║██╔══██║██╔═══╝     ██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝  ██╔══╝  ██╔══██╗
██║     ██║███████╗   ██║   ███████╗██║  ██║███████║╚███╔███╔╝██║  ██║██║         ██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║   ███████╗██║  ██║
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝         ╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝
                                                                                                                                                    
SPDX-License-Identifier: UNLICENSED

BasicToken: 0xCcAB6d9eF2056E3F190FE2d26B2a9DBb006Cae9C
DeflationaryToken: 0xc6f63D02C1405b77919199E90a3C590d6B03D14E
LiquidityGeneratorToken: 0x0

BasicMintableToken ?
DeflationaryMintableToken ?
RebaseToken ?

*/

pragma solidity ^0.8;

interface IFilterManager {
    function feeToAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function routerAddress() external view returns (address);
    function wethAddress() external view returns (address);
    function tokenMintFee() external view returns (uint);
    function maxOwnerShare() external view returns (uint);
    function numTemplates() external view returns (uint);
    function tokenTemplateAddress(uint) external view returns (address);
    function isTokenVerified(address) external view returns (bool);
    function setTokenVerified(address) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IFilterRouter {
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline, uint liquidityLockTime) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline, uint liquidityLockTime) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IFilterFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDeployedToken {
    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, uint[] memory _tokenArgs) external;
    function initializePair(address _pairAddress) external;
}

contract FilterDeployer {
    IFilterManager filterManager;

    constructor(address _managerAddress) {
        filterManager = IFilterManager(_managerAddress);
    }

    function cloneContract(address _addressToClone) private returns (address) {
        address deployedAddress;
        assembly {
            mstore(0x0, or (0x5880730000000000000000000000000000000000000000803b80938091923cF3, mul(_addressToClone, 0x1000000000000000000)))
            deployedAddress := create(0, 0, 32)
        }
        return deployedAddress;
    }

    function createTokenWithETH(
        uint _tokenType, 
        string memory _tokenName, 
        string memory _tokenSymbol, 
        uint[] memory _tokenArgs, 
        uint _ownerShare, 
        uint _deadline, 
        uint _liquidityLockTime
        ) public payable {
        require(_ownerShare <= filterManager.maxOwnerShare(), "FilterDeployer: DEV_SHARE_TOO_HIGH");
        require(_tokenType < filterManager.numTemplates(), "FilterDeployer: INVALID_TOKEN_TYPE");
        require(msg.value > 0, "FilterDeployer: NO_ETH_SUPPLIED");

        payable(filterManager.feeToAddress()).transfer((filterManager.tokenMintFee() * address(this).balance) / 1000);


        address deployedTokenAddress = cloneContract(filterManager.tokenTemplateAddress(_tokenType));

        IDeployedToken(deployedTokenAddress).initializeToken(_tokenName, _tokenSymbol, msg.sender, address(this), _tokenArgs);

        IERC20 deployedToken = IERC20(deployedTokenAddress);
        deployedToken.transfer(msg.sender, ((deployedToken.balanceOf(address(this)) * _ownerShare) / 100));

        IFilterRouter(filterManager.routerAddress()).addLiquidityETH{value: msg.value}(
            deployedTokenAddress,
            IERC20(deployedTokenAddress).balanceOf(address(this)),
            0,
            0,
            msg.sender,
            _deadline,
            _liquidityLockTime
        );

        address pairAddress = IFilterFactory(filterManager.factoryAddress()).getPair(filterManager.wethAddress(), deployedTokenAddress);
        IDeployedToken(deployedTokenAddress).initializePair(pairAddress);             

        filterManager.setTokenVerified(deployedTokenAddress);
    }

    function createTokenWithAltPair(
        uint _tokenType, 
        string memory _tokenName, 
        string memory _tokenSymbol, 
        uint[] memory _tokenArgs, 
        address _baseTokenAddress,
        uint _baseTokenAmount,
        uint _ownerShare, 
        uint _deadline, 
        uint _liquidityLockTime
        ) public {
        require(_ownerShare <= filterManager.maxOwnerShare(), "FilterDeployer: DEV_SHARE_TOO_HIGH");
        require(_tokenType < filterManager.numTemplates(), "FilterDeployer: INVALID_TOKEN_TYPE");
        require(IERC20(_baseTokenAddress).balanceOf(msg.sender) >= _baseTokenAmount, "FilterDeployer: INSUFFICIENT_BASE_TOKEN_AMOUNT");
        require(filterManager.isTokenVerified(_baseTokenAddress), "FilterDeployer: BASE_TOKEN_NOT_VERIFIED");

        IERC20(_baseTokenAddress).transferFrom(msg.sender, address(this), _baseTokenAmount);
        IERC20(_baseTokenAddress).transfer(filterManager.feeToAddress(), (filterManager.tokenMintFee() * IERC20(_baseTokenAddress).balanceOf(address(this))) / 1000);

        address deployedTokenAddress = cloneContract(filterManager.tokenTemplateAddress(_tokenType));

        IDeployedToken(deployedTokenAddress).initializeToken(_tokenName, _tokenSymbol, msg.sender, address(this), _tokenArgs);

        IERC20 deployedToken = IERC20(deployedTokenAddress);
        deployedToken.transfer(msg.sender, ((deployedToken.balanceOf(address(this)) * _ownerShare) / 100));

        IFilterRouter(filterManager.routerAddress()).addLiquidity(
            _baseTokenAddress,
            deployedTokenAddress,
            IERC20(_baseTokenAddress).balanceOf(address(this)),
            IERC20(deployedTokenAddress).balanceOf(address(this)),
            0,
            0,
            msg.sender,
            _deadline,
            _liquidityLockTime
        );

        address pairAddress = IFilterFactory(filterManager.factoryAddress()).getPair(_baseTokenAddress, deployedTokenAddress);
        IDeployedToken(deployedTokenAddress).initializePair(pairAddress);            

        filterManager.setTokenVerified(deployedTokenAddress);
    }
}