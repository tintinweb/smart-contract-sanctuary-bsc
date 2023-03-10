// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./Ownable.sol";

contract NexusGalaxy is ERC20, Ownable {
    uint public taxPercent;
    uint public backToWalletPercentage;
    uint public teamPercent;
    uint public marketingPercent;
    uint public developmentPercent;
    uint public burnPercent;
    uint public backToHoldersPercent;

    address public outTaxToken;
    IUniswapV2Router02 router;

    address backToWalletAddress;
    address teamAddress;
    address marketingAddress;
    address developmentAddress;
    address[] public recentHoldersAddress = new address[](5);
    mapping(address => bool) public noTaxAddressesTo;
    mapping(address => bool) public noTaxAddressesFrom;
    mapping(address => bool) public isLp;
    uint8 currentId;
    bool toggleTaxes;
    bool _inTaxDistribution;
    uint public totalTax = 0;

    modifier lockWhileDistribution() {
        _inTaxDistribution = true;
        _;
        _inTaxDistribution = false;
    }

    constructor(
        uint256 initialSupply,
        address _outTaxToken,
        address _router,
        address _backToWalletAddress,
        address _teamAddress,
        address _marketingAddress,
        address _developmentAddress,
        uint[] memory _taxes
    ) ERC20("Nexus Galaxy", "NXS") {
        _mint(msg.sender, initialSupply);
        outTaxToken = _outTaxToken;
        router = IUniswapV2Router02(_router);

        backToWalletAddress = _backToWalletAddress;
        teamAddress = _teamAddress;
        marketingAddress = _marketingAddress;
        developmentAddress = _developmentAddress;

        taxPercent = _taxes[0];
        backToWalletPercentage = _taxes[1];
        teamPercent = _taxes[2];
        marketingPercent = _taxes[3];
        developmentPercent = _taxes[4];
        burnPercent = _taxes[5];
        backToHoldersPercent = _taxes[6];

        toggleTaxes = true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        uint outAmount = amount;

        if (
            !_inTaxDistribution &&
            to != address(0) &&
            from != address(0) &&
            !noTaxAddressesTo[to] &&
            !noTaxAddressesFrom[from] &&
            toggleTaxes
        ) {
            uint totalTaxAmount = (amount * taxPercent) / 100;
            super._transfer(from, address(this), totalTaxAmount);
            uint backToHoldersAmount = (amount * backToHoldersPercent) / 100;
            updateAndPayRecentHolders(to, backToHoldersAmount);

            uint burnAmount = (amount * burnPercent) / 100;
            _burn(address(this), burnAmount);

            outAmount = amount - totalTaxAmount;

            totalTaxAmount -= (backToHoldersAmount + burnAmount);
            totalTax += totalTaxAmount;
        }
        super._transfer(from, to, outAmount);
    }

    function releaseTaxes(
        uint releaseAmount
    ) public lockWhileDistribution onlyOwner {
        require(totalTax > 0, "No tax Collected");
        require(releaseAmount <= totalTax, "invalid release amount");

        super._approve(address(this), address(router), releaseAmount);

        uint backToWalletAmount = (releaseAmount * backToWalletPercentage) / 6;
        SwapandPayTaxes(backToWalletAddress, backToWalletAmount);

        uint teamAmount = (releaseAmount * teamPercent) / 6;
        SwapandPayTaxes(teamAddress, teamAmount);

        uint marketingAmount = (releaseAmount * marketingPercent) / 6;
        SwapandPayTaxes(marketingAddress, marketingAmount);

        uint developmentAmount = (releaseAmount * developmentPercent) / 6;
        SwapandPayTaxes(developmentAddress, developmentAmount);

        totalTax -= releaseAmount;
    }

    function SwapandPayTaxes(address _taxReciever, uint _amount) private {
        address[] memory path = new address[](2);
        path[0] = address(address(this));
        path[1] = address(outTaxToken);
        uint256 outputAmount = router.getAmountsOut(_amount, path)[1];

        router.swapExactTokensForTokens(
            _amount,
            outputAmount,
            path,
            _taxReciever,
            block.timestamp
        );
    }

    function updateAndPayRecentHolders(
        address addr,
        uint value
    ) private lockWhileDistribution {
        for (uint i = 0; i < recentHoldersAddress.length; i++) {
            if (
                recentHoldersAddress[i] != address(0) &&
                !isLp[recentHoldersAddress[i]]
            )
                super._transfer(
                    address(this),
                    recentHoldersAddress[i],
                    value / recentHoldersAddress.length
                );
        }

        if (isLp[addr]) {
            return;
        }

        recentHoldersAddress[currentId] = addr;
        if (currentId == 4) {
            currentId = 0;
        } else {
            currentId++;
        }
    }

    function withdrawTokens(
        address tokensAddrs,
        address to,
        uint amount
    ) public lockWhileDistribution onlyOwner {
        IERC20(tokensAddrs).transfer(to, amount);
    }

    function setNoTaxAddressesTo(address addr, bool permit) public onlyOwner {
        noTaxAddressesTo[addr] = permit;
    }

    function setNoTaxAddressesFrom(address addr, bool permit) public onlyOwner {
        noTaxAddressesFrom[addr] = permit;
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

    function addLp(address lpAddr, bool toggle) public onlyOwner {
        isLp[lpAddr] = toggle;
    }

    function toggleTax(bool toggle) public onlyOwner {
        toggleTaxes = toggle;
    }
}