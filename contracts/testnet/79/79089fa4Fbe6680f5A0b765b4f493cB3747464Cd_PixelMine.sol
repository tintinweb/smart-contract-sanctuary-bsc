/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// Items, NFTs or resources
interface PixelMineItem {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function balanceOf(address acount) external returns (uint256);
    function decimals() external returns(uint);

    // Used by resources - items/NFTs won't have this will this be an issue?
    function stake(address account, uint256 amount) external;
    function getStaked(address account) external returns(uint256);
    function allowance(address owner, address spender) external returns(uint256);
    function transferFrom(address sender, address receiver, uint256 amount) external;
    function totalSupply() external returns(uint256);
    function transfer(address sender, uint256 amount) external;
}

contract PixelMine {
    using SafeMath for uint256;

    address private _tokenAddress = 0x341a664dDcaa42cdaf639cd988B4276C0CA28ED1;

    address private _presaleHELMETMinter;
    address private _presaleShovelMinter;
    address private _minter;

    address private _helmetAddress = 0x0e6081E9eABaDA65B4bDD45E5d28C9dD08aaDF90;
    address private _shovelAddress = 0xABa8082567bb2D618d06346Cf3E32FD6Ad3c36a4;
    address private _hammerAddress = 0xE5423fbCD3a62c3Adf09dc787CBbcd43E4bcF2A5;
    address private _axeAddress = 0xfB22eec5a7c7b23CA9b9E683b4C6E0f5d815aa47;
    address private _drillAddress = 0xC331dFCa624414E62DbB944595269dD878FB2Fb1;

    address private _BNBLiquidityAddress = 0x664a2c7fC71c0CbB03B9302Fb3B5876aEe1D76Db;
    address private _BUSDLiquidityAddress = 0x664a2c7fC71c0CbB03B9302Fb3B5876aEe1D76Db;
    address private _advisorAddress = 0x664a2c7fC71c0CbB03B9302Fb3B5876aEe1D76Db;
    address private _teamAddress = 0x664a2c7fC71c0CbB03B9302Fb3B5876aEe1D76Db;
    address private _designerAddress = 0x664a2c7fC71c0CbB03B9302Fb3B5876aEe1D76Db;

    address private _busdContractAddress = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;

    constructor() {
        _minter = msg.sender;
    }

    function passPresaleHELMETMinterRole() public {
        require(msg.sender == _minter, "You are not able to pass the role");
        _presaleHELMETMinter = address(this);
    }

    function passPresaleShovelMinterRole() public {
        require(msg.sender == _minter, "You are not able to pass the role");
        _presaleShovelMinter = address(this);
    }

    /*-----------------------------------------------------------------------------------
    -----------------------------                        --------------------------------
    -----------------------------      Farm Related      --------------------------------
    -----------------------------      Gaming State      --------------------------------
    -----------------------------                        --------------------------------
    -------------------------------------------------------------------------------------*/
    enum Action { Plant, Harvest }
    enum ORE { None, Stone, Coal, Iron, Bauxite, Phospate, Sulfur, Silver, Gold, Diamond }

    struct MiningFarm {
        ORE fruit;
        uint createdAt;
    }

    uint farmCount = 0;
    mapping(address => MiningFarm[]) fields;
    mapping(address => uint) syncedAt;
    mapping(address => uint) rewardsOpenedAt;

    event FarmCreated(address indexed _address);
    event FarmSynced(address indexed _address);
    event ItemCrafted(address indexed _address, address _item);

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    /*------------------------------------------------------------------------------------------
                            Should implement Tokenomic1 here
    --------------------------------------------------------------------------------------------*/ 
    function createMiningFarm() public payable {
        require(syncedAt[msg.sender] == 0, "FARM_EXISTS");

        uint decimals = PixelMineItem(_tokenAddress).decimals();

        require(
            // Donation must be at least $0.02 to play
            msg.value >= 2 * 10**(decimals - 2),
            "INSUFFICIENT_DONATION"
        );

        MiningFarm[] storage land = fields[msg.sender];
        MiningFarm memory empty = MiningFarm({
            fruit: ORE.None,
            createdAt: 0
        });
        MiningFarm memory stone = MiningFarm({
            fruit: ORE.Stone,
            createdAt: 0
        });

        // Each farmer starts with 5 fields & 3 stones
        land.push(empty);
        land.push(stone);
        land.push(stone);
        land.push(stone);
        land.push(empty);

        syncedAt[msg.sender] = block.timestamp;
        // They must wait X days before opening their first reward
        rewardsOpenedAt[msg.sender] = block.timestamp;

        (bool sent, ) = _BNBLiquidityAddress.call{value: msg.value / 2}("");
        require(sent, "DONATION_FAILED");

        farmCount += 1;

        //Emit an event
        emit FarmCreated(msg.sender);
    }

    function lastSyncedAt(address owner) private view returns(uint) {
        return syncedAt[owner];
    }

    function getLand(address owner) public view returns (MiningFarm[] memory) {
        return fields[owner];
    }

    struct Event { 
        Action action;
        ORE fruit;
        uint landIndex;
        uint createdAt;
    }

    struct Farm {
        MiningFarm[] land;
        uint balance;
    }

    function getHarvestSeconds(ORE _ore) private pure returns (uint) {
        if (_ore == ORE.Stone) {
            // 1 minute
            return 1 * 60;
        } else if (_ore == ORE.Coal) {
            // 5 minutes
            return 5 * 60;
        } else if (_ore == ORE.Iron) {
            // 1 hour
            return 1  * 60 * 60;
        } else if (_ore == ORE.Bauxite) {
            // 4 hours
            return 2 * 60 * 60;
        } else if (_ore == ORE.Phospate) {
            // 8 hours
            return 6 * 60 * 60;
        } else if (_ore == ORE.Sulfur) {
            // 1 day
            return 8 * 60 * 60;
        } else if (_ore == ORE.Silver) {
            // 3 days
            return 10 * 60 * 60;
        } else if (_ore == ORE.Gold) {
            // 3 days
            return 1 * 24 * 60 * 60;
        } else if (_ore == ORE.Diamond) {
            // 3 days
            return 3 * 24 * 60 * 60;
        }

        require(false, "INVALID_FRUIT");
        return 9999999;
    }

    function getStartPrice(ORE _ore) private returns (uint price) {
        uint marketRate = getMarketRate();
        uint decimals = PixelMineItem(_tokenAddress).decimals();

        if (_ore == ORE.Stone) {
            // $0.002
            return 2 * 10**decimals / marketRate / 1000;
        } else if (_ore == ORE.Coal) {
            // $0.02
            return 2 * 10**decimals / marketRate / 100;
        } else if (_ore == ORE.Iron) {
            // $0.12
            return 12 * 10**decimals / marketRate / 100;
        } else if (_ore == ORE.Bauxite) {
            // 0.2
            return 2 * 10**decimals / marketRate / 10;
        } else if (_ore == ORE.Phospate) {
            // 0.4
            return 4 * 10**decimals / marketRate / 10;
        } else if (_ore == ORE.Sulfur) {
            // 0.6
            return 6 * 10**decimals / marketRate / 10;
        } else if (_ore == ORE.Silver) {
            // 1
            return 1 * 10**decimals / marketRate;
        } else if (_ore == ORE.Gold) {
            // 6
            return 6 * 10**decimals / marketRate;
        } else if (_ore == ORE.Diamond) {
            // 12
            return 12 * 10**decimals / marketRate;
        }

        require(false, "INVALID_ORE");

        return 100000 * 10**decimals;
    }

    function getHarvestPrice(ORE _ore) private returns (uint price) {
        uint marketRate = getMarketRate();
        uint decimals = PixelMineItem(_tokenAddress).decimals();

        if (_ore == ORE.Stone) {
            // $0.004
            return 4 * 10**decimals / marketRate / 1000;
        } else if (_ore == ORE.Coal) {
            // $0.03
            return 3 * 10**decimals / marketRate / 100;
        } else if (_ore == ORE.Iron) {
            // $0.24
            return 24 * 10**decimals / marketRate / 100;
        } else if (_ore == ORE.Bauxite) {
            // 0.36
            return 36 * 10**decimals / marketRate / 100;
        } else if (_ore == ORE.Phospate) {
            // 0.6
            return 6 * 10**decimals / marketRate / 10;
        } else if (_ore == ORE.Sulfur) {
            // 1.2
            return 12 * 10**decimals / marketRate / 10;
        } else if (_ore == ORE.Silver) {
            // 2
            return 2 * 10**decimals / marketRate;
        } else if (_ore == ORE.Gold) {
            // 12
            return 12 * 10**decimals / marketRate;
        } else if (_ore == ORE.Diamond) {
            // 24
            return 24 * 10**decimals / marketRate;
        }

        require(false, "INVALID_ORE");

        return 0;
    }
    
    function requiredLandSize(ORE _ore) private pure returns (uint size) {
        if (_ore == ORE.Stone || _ore == ORE.Coal) {
            return 5;
        } else if (_ore == ORE.Iron || _ore == ORE.Bauxite) {
            return 8;
        } else if (_ore == ORE.Phospate) {
            return 11;
        } else if (_ore == ORE.Sulfur || _ore == ORE.Silver) {
            return 14;
        } else if (_ore == ORE.Gold || _ore == ORE.Diamond) {
            return 17;
        }

        require(false, "INVALID_ORE");

        return 99;
    }
    
    function getLandPrice(uint landSize) private returns (uint price) {
        uint decimals = PixelMineItem(_tokenAddress).decimals();
        if (landSize <= 5) {
            // $2
            return 2 * 10**decimals;
        } else if (landSize <= 8) {
            // 10
            return 10 * 10**decimals;
        } else if (landSize <= 11) {
            // $20
            return 20 * 10**decimals;
        }
        
        // $100
        return 100 * 10**decimals;
    }

    modifier hasFarm {
        require(lastSyncedAt(msg.sender) > 0, "NO_FARM");
        _;
    }

    uint private THIRTY_MINUTES = 30 * 60;

    function buildFarm(Event[] memory _events) private hasFarm returns (Farm memory currentFarm) {
        MiningFarm[] memory land = fields[msg.sender];
        uint balance = PixelMineItem(_tokenAddress).balanceOf(msg.sender);

        for (uint index = 0; index < _events.length; index++) {
            Event memory farmEvent = _events[index];

            uint thirtyMinutesAgo = block.timestamp.sub(THIRTY_MINUTES); 
            require(farmEvent.createdAt >= thirtyMinutesAgo, "EVENT_EXPIRED");
            require(farmEvent.createdAt >= lastSyncedAt(msg.sender), "EVENT_IN_PAST");
            require(farmEvent.createdAt <= block.timestamp, "EVENT_IN_FUTURE");

            if (index > 0) {
                require(farmEvent.createdAt >= _events[index - 1].createdAt, "INVALID_ORDER");
            }

            if (farmEvent.action == Action.Plant) {
                require(land.length >= requiredLandSize(farmEvent.fruit), "INVALID_LEVEL");

                uint price = getStartPrice(farmEvent.fruit);
                uint fmcPrice = getMarketPrice(price);
                require(balance >= fmcPrice, "INSUFFICIENT_FUNDS");

                balance = balance.sub(fmcPrice);

                MiningFarm memory plantedSeed = MiningFarm({
                    fruit: farmEvent.fruit,
                    createdAt: farmEvent.createdAt
                });
                land[farmEvent.landIndex] = plantedSeed;
            } else if (farmEvent.action == Action.Harvest) {
                MiningFarm memory miningFarm = land[farmEvent.landIndex];
                require(miningFarm.fruit != ORE.None, "NO_FRUIT");

                uint duration = farmEvent.createdAt.sub(miningFarm.createdAt);
                uint secondsToHarvest = getHarvestSeconds(miningFarm.fruit);
                require(duration >= secondsToHarvest, "NOT_RIPE");

                // Clear the land
                MiningFarm memory emptyLand = MiningFarm({
                    fruit: ORE.None,
                    createdAt: 0
                });
                land[farmEvent.landIndex] = emptyLand;

                uint price = getHarvestPrice(miningFarm.fruit);
                uint fmcPrice = getMarketPrice(price);

                balance = balance.add(fmcPrice);
            }
        }

        return Farm({
            land: land,
            balance: balance
        });
    }

    function sync(Event[] memory _events) public hasFarm returns (Farm memory) {
        Farm memory farm = buildFarm(_events);

        // Update the land
        MiningFarm[] storage land = fields[msg.sender];
        for (uint i=0; i < farm.land.length; i += 1) {
            land[i] = farm.land[i];
        }
        
        syncedAt[msg.sender] = block.timestamp;
        
        uint balance = PixelMineItem(_tokenAddress).balanceOf(msg.sender);
        // Update the balance - mint or burn
        if (farm.balance > balance) {
            uint profit = farm.balance.sub(balance);
            PixelMineItem(_tokenAddress).mint(msg.sender, profit);
        } else if (farm.balance < balance) {
            uint loss = balance.sub(farm.balance);
            PixelMineItem(_tokenAddress).burn(msg.sender, loss);
        }

        emit FarmSynced(msg.sender);

        return farm;
    }

    /*------------------------------------------------------------------------------------------
                            Should implement Tokenomic3 here
    --------------------------------------------------------------------------------------------*/ 
    function levelUp() public hasFarm {
        require(fields[msg.sender].length <= 17, "MAX_LEVEL");

        MiningFarm[] storage land = fields[msg.sender];

        uint price = getLandPrice(land.length);
        uint fmcPrice = getMarketPrice(price);
        uint balance = PixelMineItem(_tokenAddress).balanceOf(msg.sender);

        require(balance >= fmcPrice, "INSUFFICIENT_FUNDS");
        
        uint liquidity = fmcPrice / 10 / 2 * 5;
        uint advisor = fmcPrice / 10 * 1;
        uint drillRewards = fmcPrice / 10 * 2;
        uint team = fmcPrice / 10 * 2;

        // Store rewards in the Farm Contract to redistribute
        PixelMineItem(_tokenAddress).transferFrom(msg.sender, address(this), drillRewards);
        PixelMineItem(_tokenAddress).transferFrom(msg.sender, _BNBLiquidityAddress, liquidity);
        PixelMineItem(_tokenAddress).transferFrom(msg.sender, _BUSDLiquidityAddress, liquidity);
        PixelMineItem(_tokenAddress).transferFrom(msg.sender, _advisorAddress, advisor);
        PixelMineItem(_tokenAddress).transferFrom(msg.sender, _teamAddress, team);

        // Add 3 stone fields in the new fields
        MiningFarm memory stone = MiningFarm({
            fruit: ORE.Stone,
            // Make them immediately harvestable in case they spent all their tokens
            createdAt: 0
        });

        for (uint index = 0; index < 3; index++) {
            land.push(stone);
        }

        emit FarmSynced(msg.sender);
    }

    // How many tokens do you get per dollar
    // Algorithm is totalSupply / 10000 but we do this in gradual steps to avoid widly flucating prices between plant & harvest
    function getMarketRate() private returns (uint conversion) {
        uint decimals = PixelMineItem(_tokenAddress).decimals();
        uint totalSupply = PixelMineItem(_tokenAddress).totalSupply();

        // Less than 500, 000 tokens
        if (totalSupply < (500000 * 10**decimals)) {
            return 2;
        }

        // Less than 1, 000, 000 tokens
        if (totalSupply < (1000000 * 10**decimals)) {   
            return 4;
        }

        // Less than 5, 000, 000 tokens
        if (totalSupply < (5000000 * 10**decimals)) {
            return 8;
        }

        // Less than 10, 000, 000 tokens
        if (totalSupply < (10000000 * 10**decimals)) {
            return 16;
        }

        // 1 Farm Dollar gets you a 0.00001 of a token - Linear growth from here
        return totalSupply.div(10000);
    }

    function getMarketPrice(uint price) public returns (uint conversion) {
        uint marketRate = getMarketRate();

        return price.div(marketRate);
    }

    function getFarm(address account) public view returns (MiningFarm[] memory farm) {
        return fields[account];
    }

    function getFarmCount() public view returns (uint count) {
        return farmCount;
    }

    /*-----------------------------------------------------------------------------------
    -----------------------------                        --------------------------------
    -----------------------------      NFT Rewords       --------------------------------
    -----------------------------        Related         --------------------------------
    -----------------------------                        --------------------------------
    -------------------------------------------------------------------------------------*/

    // Depending on the fields you have determines your cut of the rewards.
    function myReward() public hasFarm returns (uint amount) {        
        uint lastOpenDate = rewardsOpenedAt[msg.sender];

        // Block timestamp is seconds based
        uint threeDaysAgo = block.timestamp.sub(60 * 60 * 24 * 3); 

        require(lastOpenDate < threeDaysAgo, "NO_REWARD_READY");

        uint landSize = fields[msg.sender].length;
        // E.g. $1000
        uint farmBalance = PixelMineItem(_tokenAddress).balanceOf(address(this));
        // E.g. $1000 / 500 farms = $2 
        uint farmShare = farmBalance / shovelholders.length;

        if (landSize <= 5) {
            // E.g $0.2
            return farmShare.div(10);
        } else if (landSize <= 8) {
            // E.g $0.4
            return farmShare.div(5);
        } else if (landSize <= 11) {
            // E.g $1
            return farmShare.div(2);
        }
        
        // E.g $3
        return farmShare.mul(3).div(2);
    }

    function receiveReward() public hasFarm {
        (bool _is,) = isShovelHolder(msg.sender);
        require(_is, "You can't get reward.");

        uint amount = myReward();

        require(amount > 0, "NO_REWARD_AMOUNT");

        rewardsOpenedAt[msg.sender] = block.timestamp;

        PixelMineItem(_tokenAddress).transfer(msg.sender, amount);
    }

    
    /*-----------------------------------------------------------------------------------
    -----------------------------                        --------------------------------
    -----------------------------      NFT Holders       --------------------------------
    -----------------------------        Related         --------------------------------
    -----------------------------                        --------------------------------
    -------------------------------------------------------------------------------------*/
    address[] internal helmetholders;
    address[] internal shovelholders;

        /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */

    function isHelmetholder(address _address)
        public
        view
    returns(bool, uint256)
    {
        for (uint256 s = 0; s < helmetholders.length; s += 1){
            if (_address == helmetholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function isShovelHolder(address _address)
        public
        view
    returns(bool, uint256)
    {
        for (uint256 s = 0; s < shovelholders.length; s += 1){
            if (_address == shovelholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
    function addHelmetholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isHelmetholder(_stakeholder);
        if(!_isStakeholder) helmetholders.push(_stakeholder);
    }

    function addShovelHolder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isShovelHolder(_stakeholder);
        if(!_isStakeholder) shovelholders.push(_stakeholder);
    }
    
    /*-----------------------------------------------------------------------------------
    -----------------------------                        --------------------------------
    -----------------------------      NFT Minting       --------------------------------
    -----------------------------        Related         --------------------------------
    -----------------------------                        --------------------------------
    -------------------------------------------------------------------------------------*/

    function isAllowedToHelmet(address account) private returns(bool) {
        if (PixelMineItem(_helmetAddress).balanceOf(account) < 1) return true;
        return false;
    }

    function isAllowedToAxe(address account) private returns(bool) {
        if (PixelMineItem(_axeAddress).balanceOf(account) < 1) return true;
        return false;
    }

    function isAllowedToHammer(address account) private returns(bool) {
        if (PixelMineItem(_hammerAddress).balanceOf(account) < 1) return true;
        return false;
    }

    function isAllowedToDrill(address account) private returns(bool) {
        if (PixelMineItem(_drillAddress).balanceOf(account) < 1) return true;
        return false;
    }

    function isAllowedToShovel(address account) private returns(bool) {
        if (PixelMineItem(_shovelAddress).balanceOf(account) < 1) return true;
        return false;
    }

    function isApprovedAndTransfered(address account, uint amount) private returns(bool) {
        if (PixelMineItem(_busdContractAddress).allowance(account, address(this)) >= amount) {
            PixelMineItem(_busdContractAddress).transferFrom(account, _BUSDLiquidityAddress, amount / 2);
            PixelMineItem(_busdContractAddress).transferFrom(account, address(this), amount / 2);
            return true;
        }
        return false;
    }

    function _mintHelmet(address account) private {
        if (isAllowedToHelmet(account)) PixelMineItem(_helmetAddress).mint(account, 1);
    }

    function _mintShovel(address account) private {
        if (isAllowedToShovel(account)) PixelMineItem(_shovelAddress).mint(account, 1);
    }

    function _mintDrill(address account) private {
        if (isAllowedToDrill(account)) PixelMineItem(_drillAddress).mint(account, 1);
    }

    function _mintHammer(address account) private {
        if (isAllowedToHammer(account)) PixelMineItem(_hammerAddress).mint(account, 1);
    }

    function _mintAxe(address account) private {
        if (isAllowedToAxe(account)) PixelMineItem(_axeAddress).mint(account, 1);
    }

    function presaleMintHELMET() public payable {
        require(_presaleHELMETMinter == address(0), "Unable to presale mint HELMET");
        require(msg.value == 1 * 10 ** 18, "Unable to mint: Fixed Price 1 BNB");
        (bool sent,) = _BNBLiquidityAddress.call{value: msg.value / 2}("");
        require(sent, "Failed to mint");
        _mintHelmet(msg.sender);
        _mintHammer(msg.sender);
        _mintDrill(msg.sender);
        _mintAxe(msg.sender);
        addHelmetholder(msg.sender);
    }

    function presaleMintShovel() public {
        require(_presaleShovelMinter == address(0), "Unable to presale mint Shovel");
        require(isApprovedAndTransfered(msg.sender, 300 * 10 ** 18), "Unable to mint: Fixed Price 300 BUSD");
        _mintShovel(msg.sender);
        _mintHammer(msg.sender);
        _mintDrill(msg.sender);
        _mintAxe(msg.sender);
        addShovelHolder(msg.sender);
    }

    function mintNFT(address tokenAddress) public payable {
        if (tokenAddress == _helmetAddress) {
            require(msg.value == 1 * 10 ** 18, "Unable to mint: Fixed Price 1 BNB");
            (bool sent,) = _BNBLiquidityAddress.call{value: msg.value / 2}("");
            require(sent, "Failed to mint");
            _mintHelmet(msg.sender);
            addHelmetholder(msg.sender);
        } 
        else if (tokenAddress == _shovelAddress) {
            require(isApprovedAndTransfered(msg.sender, 300 * 10 ** 18), "Unable to mint: Fixed Price 300 BUSD");
            _mintShovel(msg.sender);
            addShovelHolder(msg.sender);
        }
        else {
            require(isApprovedAndTransfered(msg.sender, 200 * 10 ** 18), "Unable to mint: Fixed Price 200 BUSD");
            PixelMineItem(tokenAddress).mint(msg.sender, 1);
        }

        emit ItemCrafted(msg.sender, tokenAddress);
    }

    function withdrawBNBForProviders() public returns(bool) {
        require(address(this).balance > 0, "Unable to withdraw!");
        uint balance = address(this).balance;
        bool sent = false;
        (sent,) = _advisorAddress.call{value: balance / 10}("");
        if (!sent) return false;
        (sent,) = _teamAddress.call{value: balance / 10 * 3}("");
        if (!sent) return false;
        uint length = helmetholders.length;
        for (uint i=0; i<length; i++) {
            (sent,) = helmetholders[i].call{value: balance / length / 10 * 3}("");
            if (!sent) return false;
        }
        return true;
    }

    function withdrawBUSDForProviders() public returns(bool) {
        require(PixelMineItem(_busdContractAddress).balanceOf(address(this)) > 0, "Unable to withdraw!");
        uint balance = PixelMineItem(_busdContractAddress).balanceOf(address(this));
        PixelMineItem(_busdContractAddress).transfer(_designerAddress, balance / 5);
        PixelMineItem(_advisorAddress).transfer(_designerAddress, balance / 5);
        PixelMineItem(_teamAddress).transfer(_designerAddress, balance / 5 * 2);
        return true;
    }
}