// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./Ownable.sol";

contract NexusGBS is ERC20, Ownable {

    
    uint public taxPercent = 10;  
    uint public backToWalletPercentage = 1;
    uint public teamPercent = 2;
    uint public marketingPercent = 1;
    uint public developmentPercent = 2;
    uint public burnPercent = 2;
    uint public backToHoldersPercent = 2;

    address public outTaxToken;
    IUniswapV2Router02 router;

    address backToWalletAddress;
    address teamAddress;
    address marketingAddress;
    address developmentAddress;
    address[] public recentHoldersAddress = new address[](5);
    mapping(address=> bool) public noTaxAddresses;
    mapping(address=> bool) public isLp;
    uint8 currentId;
    bool _inTaxDistribution;
    uint public totalTax = 0;

    modifier lockWhileDistribution {
        _inTaxDistribution = true;
        _;
        _inTaxDistribution = false;
    } 

    
    constructor(uint256 initialSupply, address _outTaxToken, address _router, address _backToWalletAddress, address _teamAddress, address _marketingAddress, address _developmentAddress) ERC20("GBSToken", "GBST1") {
        _mint(msg.sender, initialSupply);
        outTaxToken = _outTaxToken;
        router = IUniswapV2Router02(_router);

        backToWalletAddress = _backToWalletAddress;
        teamAddress = _teamAddress;
        marketingAddress = _marketingAddress;
        developmentAddress = _developmentAddress;
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        uint outAmount = amount;

        if(!_inTaxDistribution && to != address(0) && from != address(0) && !noTaxAddresses[from]){ 
        uint totalTaxAmount = (amount*taxPercent)/100;
        super._transfer(from, address(this), totalTaxAmount);
        uint backToHoldersAmount = (amount*backToHoldersPercent)/100;
        updateAndPayRecentHolders(from, backToHoldersAmount);

        uint burnAmount = (amount*burnPercent)/100;
        _burn(address(this), burnAmount);

        outAmount = amount - totalTaxAmount;

        totalTaxAmount -= (backToHoldersAmount+burnAmount);
        totalTax += totalTaxAmount;
        }
        super._transfer(from, to, outAmount);
        
       
    }

    function releaseTaxes() public lockWhileDistribution onlyOwner {

        require(totalTax > 0,"No tax Collected");

        super._approve(address(this), address(router), totalTax);
        
        uint backToWalletAmount = (totalTax*backToWalletPercentage)/6;
        SwapandPayTaxes(backToWalletAddress, backToWalletAmount);

        uint teamAmount = (totalTax*teamPercent)/6;
        SwapandPayTaxes(teamAddress, teamAmount);

        uint marketingAmount = (totalTax*marketingPercent)/6;
        SwapandPayTaxes(marketingAddress, marketingAmount);

        uint developmentAmount = (totalTax*developmentPercent)/6;
        SwapandPayTaxes(developmentAddress, developmentAmount);

        totalTax = 0;
    }

    function SwapandPayTaxes(address _taxReciever, uint _amount) private{

        address[] memory path = new address[](2);
        path[0] = address(address(this));
        path[1] = address(outTaxToken);
        uint256 outputAmount = router.getAmountsOut(_amount, path)[1];

        router.swapExactTokensForTokens(_amount, outputAmount, path, _taxReciever, block.timestamp);

    }

    function updateAndPayRecentHolders(address addr, uint value) private lockWhileDistribution{

        if(isLp[addr]){
            return;
        }

        for(uint i=0; i<recentHoldersAddress.length; i++){ 
            if(recentHoldersAddress[i] != address(0))
                super._transfer(address(this), recentHoldersAddress[i], value/recentHoldersAddress.length);
        }
        recentHoldersAddress[currentId] = addr;
        if(currentId == 4){
            currentId = 0;
        }else{
            currentId++;
        }
    }

    function createNewTokens(address addr, uint amount) public onlyOwner {
        _mint(addr, amount);
    }

    function burnTokens(address addr, uint amount) public onlyOwner {
        _burn(addr, amount);
    }
    
    function withdrawTokens(address tokensAddrs, address to,  uint amount) public onlyOwner {
        IERC20(tokensAddrs).transfer(to, amount);
    }

    function setNoTaxAddresses(address addr, bool permit) public onlyOwner {
        noTaxAddresses[addr] = permit;
    }

    function setBackToWalletAddress(address addr) public onlyOwner {
        backToWalletAddress = addr;
    }
    function setTeamAddress(address addr) public onlyOwner {
        teamAddress = addr;
    }
    function setMarketingAddress(address addr) public onlyOwner {
        marketingAddress = addr;
    }
    function setDevelopmentAddress(address addr) public onlyOwner {
        developmentAddress = addr;
    }

    function setOutTaxTokenAddress(address addr) public onlyOwner {
        outTaxToken = addr;
    }

    function updateRouter(address addr) public onlyOwner {
        router = IUniswapV2Router02(addr);
    }

    function addLp(address lpAddr, bool toggle) public onlyOwner{
        isLp[lpAddr] = toggle;
    }
    

}