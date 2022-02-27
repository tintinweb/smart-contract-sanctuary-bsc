// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import './libs/Editor.sol';
import './libs/Helper.sol';
import './libs/ShibaBEP20.sol';
import './libs/SafeBEP20.sol';
import "./interfaces/ITreasury.sol";
import "./interfaces/IShadowPool.sol";
import "./interfaces/IFleet.sol";

contract Map is Editor {
    using SafeBEP20 for ShibaBEP20;

    constructor (
         ShibaBEP20 _token,
         ITreasury _treasury
        //IShadowPool _shadowPool,
        //IFleet _fleet
    ) {
        //Token = ShibaBEP20(0xd9145CCE52D386f254917e481eB44e9943F39138);
         //Treasury = ITreasury(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
         Token = _token;
         Treasury = _treasury;
        //Fleet = IFleet(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);
//        ShadowPool = IShadowPool(0x318C38d8140Cb1d4CeF6E40743457c4224d07Fd8);

        _previousBalance = 0;
        _baseTravelCost = 10**15;
        _baseTravelCooldown = 2700; //45 minutes
        _travelCooldownPerDistance = 900; //15 minutes
        _maxTravel = 5; //AU
        _rewardsTimer = 0;
        rewardsDelay = 1;
        _timeModifier = 500;
        _miningCooldown = 1800; //30 minutes
        _minTravelSize = 25;
        _collectCooldownReduction = 5;
        _asteroidCooldownReduction = 3;

        _addStar(2, 2, 'Alpha Centauri', 9); // first star
        _addPlanet(0, 0, 0, 'Haven', false, true, true); //Haven
        _addPlanet(0, 3, 0, 'Cetrus 22A', true, false, false); //unrefined planet
        _addPlanet(0, 1, 6, 'Cetrus 22B', true, false, false); //unrefined planet
    }

    ShibaBEP20 public Token; // TOKEN Token
    ITreasury public Treasury; //Contract that collects all Token payments
    IShadowPool public ShadowPool; //Contract that collects Token emissions
    IFleet public Fleet; // Fleet Contract

    uint public _previousBalance; // helper for allocating Token
    uint _rewardsMod; // = x/100, the higher the number the more rewards sent to this contract
    uint _rewardsTimer; // Rewards can only be pulled from shadow pool every 4 hours?
    uint rewardsDelay;
    uint  _timeModifier; //allow all times to be changed
    uint _miningCooldown; // how long before 
    uint _minTravelSize; //min. fleet size required to travel
    uint _collectCooldownReduction;
    uint _asteroidCooldownReduction;

    // Fleet Info and helpers
    mapping (address => uint[2]) fleetLocation; //address to [x,y] array
    mapping(uint => mapping (uint => address[])) fleetsAtLocation; //reverse index to see what fleets are at what location

    mapping (address => uint) public travelCooldown; // limits how often fleets can travel
    mapping (address => uint) public fleetMiningCooldown; // limits how often a fleet can mine mineral
    mapping (address => uint) public fleetLastShipyardPlace; // last shipyard place that fleet visited
    
    uint _baseTravelCooldown; 
    uint _travelCooldownPerDistance; 
    uint _baseTravelCost; // Token cost to travel 1 AU
    uint _maxTravel; // max distance a fleet can travel in 1 jump

    enum PlaceType{ UNEXPLORED, EMPTY, HOSTILE, STAR, PLANET, ASTEROID, WORMHOLE }

    struct Place {
        uint id; //native key 
        PlaceType placeType;
        uint childId;
        uint coordX;
        uint coordY;
        string name;
        uint salvage;
        address discoverer;
        bool canTravel;
    }
    Place[] public places;
    mapping (uint => mapping(uint => bool)) _placeExists;
    mapping (uint => mapping(uint => uint)) public coordinatePlaces;

    struct PlaceGetter {
        string name;
        PlaceType placeType;
        uint salvage;
        uint fleetCount;
        bool hasRefinery;
        bool hasShipyard;
        uint availableMineral;
        bool canTravel;
        uint luminosity;
        bool isMiningPlanet;
        address discoverer;
    }

    struct Planet {
        uint id; //native key
        uint placeId; //foreign key to places
        uint starId; //foreign key to stars
        uint starDistance;
        bool isMiningPlanet;
        uint availableMineral;
        bool hasRefinery;
        bool hasShipyard;
    }
    Planet[] _planets;

    struct Star {
        uint id; //native key
        uint placeId; //foreign key to places
        uint luminosity;
        uint totalMiningPlanets;
        uint totalMiningPlanetDistance;
    }
    Star[] _stars;

    struct Asteroid {
        uint id;
        uint placeId;
        uint availableMineral;
    }
    Asteroid[] _asteroids;

    event NewShadowPool(address _new);
    event NewFleet(address _new);
    event NewToken(address _new);
    event NewTreasury(address _new);
    event NewRewardsMod(uint _new);
    event MineralGained(address _player, int _amountGained, uint _amountBurned);
    event MineralTransferred(address _from, address _to, uint _amountSent, uint _amountReceived, uint _amountBurned);
    event MineralRefined(address _fleet, uint _amount);
    event MineralGathered(address _fleet, uint _amount);
    event NewPlanet(uint _star, uint _x, uint _y);
    event NewStar(uint _x, uint _y);

    function _addPlace(PlaceType _placeType, uint _childId, uint _x, uint _y, string memory _name, bool _canTravel) internal {
        require(_placeExists[_x][_y] == false, 'Place already exists');
        uint placeId = places.length;
        places.push(Place(placeId, _placeType, _childId, _x, _y, _name, 0, tx.origin, _canTravel));

        //set place in coordinate mapping
        _placeExists[_x][_y] = true;
        coordinatePlaces[_x][_y] = placeId;
    }

    function _addEmpty(uint _x, uint _y) internal {
        _addPlace(PlaceType.EMPTY, 0, _x, _y, '', true);
    }

    function _addHostile(uint _x, uint _y) internal {
        _addPlace(PlaceType.HOSTILE, 0, _x, _y, '', false);
    }

    function _addAsteroid(uint _x, uint _y, uint _amount) internal {
        uint asteroidId = _asteroids.length;
        _asteroids.push(Asteroid(asteroidId, places.length, _amount));
        _addPlace(PlaceType.ASTEROID, asteroidId, _x, _y, '', true);
    }

    function _addStar(uint _x, uint _y, string memory _name, uint _luminosity) internal {
        //add star to stars list
        uint starId = _stars.length;
        _stars.push(Star(starId, places.length, _luminosity, 0, 0));

        _addPlace(PlaceType.STAR, starId, _x, _y, _name, false);
        emit NewStar(_x, _y);
    }

    function _addPlanet(uint _starId, uint _x, uint _y, string memory _name, bool _isMiningPlanet, bool _hasRefinery, bool _hasShipyard) internal {
        uint starX = places[_stars[_starId].placeId].coordX;
        uint starY = places[_stars[_starId].placeId].coordY;
        uint starDistance = Helper.getDistance(starX, starY, _x, _y);

        //add planet info to star
        if(_isMiningPlanet) {
            _stars[_starId].totalMiningPlanetDistance += starDistance;
            _stars[_starId].totalMiningPlanets += 1;
        }

        uint planetId = _planets.length;
        _planets.push(Planet(planetId, places.length, _starId, starDistance, _isMiningPlanet, 0, _hasRefinery, _hasShipyard));

        _addPlace(PlaceType.PLANET, planetId, _x, _y, _name, true);
        emit NewPlanet(_starId, _x, _y);
    }

    function getExploreCost(uint _x, uint _y) public view returns(uint) {
        return Helper.getDistance(0, 0, _x, _y) * 10**19 / Treasury.getCostMod();
    }

    //player explore function
    function explore(uint _x, uint _y) external {
        address sender = msg.sender;
        require(getDistanceFromFleet(sender, _x, _y) == 1, "MAPS: explore too far");
        uint exploreCost = getExploreCost(_x, _y);
        Treasury.pay(sender, exploreCost);
        Fleet.addExperience(sender, exploreCost);
        _createRandomPlaceAt(_x, _y, sender);
    }

    //create a random place at given coordinates
    function _createRandomPlaceAt(uint _x, uint _y, address _creator) internal {
        require(_placeExists[_x][_y] == false, 'Place already exists');
        uint rand = Helper.getRandomNumber(100, _x + _y);
        //uint rand = 47;
        if(rand >= 0 && rand <= 40) {
           _addHostile(_x, _y); 
        }
        else if(rand >= 41 && rand <= 49) {
            uint asteroidPercent = Helper.getRandomNumber(10, _x + _y) + 15;
            uint asteroidAmount = (asteroidPercent * Token.balanceOf(address(Treasury))) / 100;
            _previousBalance += asteroidAmount;
            Token.safeTransferFrom(address(Treasury), address(this), asteroidAmount); //send asteroid NOVA to Map contract
            _addAsteroid(_x, _y, (98 * asteroidAmount) / 100);
        }
        else if(rand >= 50 && rand <= 99) {
            uint nearestStar = _getNearestStar(_x, _y);
            uint nearestStarX = places[_stars[nearestStar].placeId].coordX;
            uint nearestStarY = places[_stars[nearestStar].placeId].coordY;

            //new planet must be within 3 AU off nearest star
            if(rand >= 50 && rand <= 65 && Helper.getDistance(_x, _y, nearestStarX, nearestStarY) <= 3) {
                bool isMiningPlanet;
                bool hasShipyard;
                bool hasRefinery;
                uint planetAttributeSelector = Helper.getRandomNumber(20, rand);
                //uint planetAttributeSelector = 19;
                if(planetAttributeSelector <= 7) {
                    isMiningPlanet = true;
                    _rewardsTimer = 0; // get rewards going to planet right away when new one is discovered
                }
                else if(planetAttributeSelector >= 8 && planetAttributeSelector <=11) {
                    hasRefinery = true;
                }
                else if(planetAttributeSelector >= 12 && planetAttributeSelector <= 18) {
                    hasShipyard = true;
                }
                else { hasShipyard = true; hasRefinery = true; }
                _addPlanet(nearestStar, _x, _y, '', isMiningPlanet, hasRefinery, hasShipyard);

                //if planet has a shipyard, add shipyard to Fleet contract
                if(hasShipyard == true) {
                    uint8 feePercent = 5;
                    address placeOwner = 0x729F3cA74A55F2aB7B584340DDefC29813fb21dF;
                    if(hasRefinery != true) {
                        feePercent = 5;
                        placeOwner = _creator;
                    }
                    Fleet.addShipyard('', placeOwner, _x, _y, feePercent);
                }
            }
            //new star must be more than 7 AU away from nearest star
            else if(rand >= 66 && Helper.getDistance(_x, _y, nearestStarX, nearestStarY) > 7) {
                _addStar(_x, _y, '', Helper.getRandomNumber(9, rand) + 1);
            }
            else {
                _addEmpty(_x, _y);
            }
        }
        else {
           _addEmpty(_x, _y);
        }
    }

    function changeName(uint _x, uint _y, string memory _name) external {
        require(bytes(_name).length <= 12, 'MAP: place name too long');
        Place storage namePlace = places[coordinatePlaces[_x][_y]];
        require(msg.sender == namePlace.discoverer, 'MAP: not discoverer');
        require(namePlace.placeType == PlaceType.PLANET || namePlace.placeType == PlaceType.STAR, 'MAP: not named');
        require(Helper.isEqual(namePlace.name, ""), 'MAP: already named');
        namePlace.name = _name;
    }

    function _getNearestStar(uint _x, uint _y) internal view returns(uint) {
        uint nearestStar;
        uint nearestStarDistance;
        for(uint i=0; i<_stars.length; i++) {
            uint starDistance = Helper.getDistance(_x, _y, places[_stars[i].placeId].coordX, places[_stars[i].placeId].coordY);
            if(nearestStarDistance == 0 || starDistance < nearestStarDistance) {
                nearestStar = i;
                nearestStarDistance = starDistance;
            }
        }
        return nearestStar;
    }

    function getCoordinatePlaces(uint _lx, uint _ly) external view returns(PlaceGetter[] memory) {
        PlaceGetter[] memory foundCoordinatePlaces = new PlaceGetter[](49);

        uint counter = 0;
        for(uint j=_ly+7; j>_ly; j--) {
            for(uint i=_lx; i<=_lx+6; i++) {
                foundCoordinatePlaces[counter++] = getPlaceInfo(i, j-1);
            }
        }
        return foundCoordinatePlaces;
    }

    function getPlaceInfo(uint _lx, uint _ly) public view returns(PlaceGetter memory) {
        PlaceGetter memory placeGetter;

        if(_placeExists[_lx][_ly] == true) {
            Place memory place = places[coordinatePlaces[_lx][_ly]];
            placeGetter.canTravel = place.canTravel;
            placeGetter.name = place.name; 
            placeGetter.placeType = place.placeType;
            placeGetter.salvage = place.salvage;
            placeGetter.fleetCount = fleetsAtLocation[_lx][_ly].length;
            placeGetter.discoverer = place.discoverer;

            if(place.placeType == PlaceType.PLANET) {
                placeGetter.hasRefinery =  _planets[place.childId].hasRefinery;
                placeGetter.hasShipyard = _planets[place.childId].hasShipyard;
                placeGetter.availableMineral = _planets[place.childId].availableMineral;
                placeGetter.isMiningPlanet = _planets[place.childId].isMiningPlanet;
            }
            else if(place.placeType == PlaceType.STAR) {
                placeGetter.luminosity = _stars[place.childId].luminosity;
            }
            else if(place.placeType == PlaceType.ASTEROID) {
                placeGetter.availableMineral = _asteroids[place.childId].availableMineral;
            }
        }
        return placeGetter;
    }

    // get total star luminosity
    function getTotalLuminosity() public view returns(uint) {
        uint totalLuminosity = 0;
        for(uint i=0; i<_stars.length; i++) {
            if(_stars[i].totalMiningPlanets > 0) {
                totalLuminosity += _stars[i].luminosity;
            }
        }
        return totalLuminosity;
    }

    function requestToken() external onlyOwner {
        _requestToken();
    }

    function _requestToken() internal {
        if (block.timestamp >= _rewardsTimer) {
            ShadowPool.replenishPlace(address(this));
            _rewardsTimer = block.timestamp + rewardsDelay;
            allocateToken();
        }
    }
    
    function addSalvageToPlace(uint _x, uint _y, uint _amount) external onlyEditor {
        //get place and add it to place
        places[coordinatePlaces[_x][_y]].salvage += _amount * 98 / 100;
    }

    // When Token allocated for salvage gets added to contract, call this function
    function increasePreviousBalance(uint _amount) external onlyEditor {
        _previousBalance += _amount * 98 / 100;
    }

    // Function to mine, refine, transfer unrefined Token
    function allocateToken() public {
        uint newAmount = Token.balanceOf(address(this)) - _previousBalance;
        if (newAmount > 0) {

            uint totalStarLuminosity = getTotalLuminosity();

            //loop through planets and add new token
            for(uint i=0; i<_planets.length; i++) {
                Planet memory planet = _planets[i];

                if(planet.isMiningPlanet) {
                    Star memory star = _stars[planet.starId];

                    uint newStarSystemToken = (newAmount * star.luminosity) / totalStarLuminosity;

                    uint newMineral = newStarSystemToken;
                    //if more than one planet in star system
                    if(star.totalMiningPlanets > 1) {
                        newMineral = newStarSystemToken * (star.totalMiningPlanetDistance - planet.starDistance) /
                            (star.totalMiningPlanetDistance * (star.totalMiningPlanets - 1));
                    }
                    _planets[i].availableMineral += newMineral;
                }
            }
            _previousBalance = Token.balanceOf(address(this));
        }
    }

    function _getPlanetAtLocation(uint _x, uint _y) internal view returns (Planet memory) {
        Planet memory planet;
        Place memory place = places[coordinatePlaces[_x][_y]];
        if(place.placeType == PlaceType.PLANET) {
            planet = _planets[place.childId];
        }
        return planet;
    }

    function getPlanetAtFleetLocation(address _sender) internal view returns (Planet memory) {
        (uint fleetX, uint fleetY) =  getFleetLocation(_sender);
        return _getPlanetAtLocation(fleetX, fleetY);
    }

    function isRefineryLocation(uint _x, uint _y) external view returns (bool) {
        return _getPlanetAtLocation(_x, _y).hasRefinery;
    }

    function isShipyardLocation(uint _x, uint _y) public view returns (bool) {
        return _getPlanetAtLocation(_x, _y).hasShipyard;
    }

    //shared core implementation for any kind of mineral/salvage collection
    function _gather(address _player, uint _locationAmount, uint _coolDown) internal returns(uint) {
        require(_locationAmount > 0, 'MAP: nothing to gather');
        require(fleetMiningCooldown[_player] <= block.timestamp, 'MAP: gather on cooldown');

        uint availableCapacity = Fleet.getMineralCapacity(_player) - Fleet.getMineral(_player); //max amount of mineral fleet can carry minus what fleet already is carrying
        require(availableCapacity > 0, 'MAP: fleet max capacity');
        
        uint maxGather = Helper.getMin(availableCapacity, Fleet.getMiningCapacity(_player));
        uint gatheredAmount = Helper.getMin(_locationAmount, maxGather); //the less of fleet maxGather and how much amount place has

        Fleet.setMineral(_player, Fleet.getMineral(_player) + gatheredAmount);
        fleetMiningCooldown[_player] = block.timestamp + (_coolDown / _timeModifier);

        emit MineralGathered(_player, gatheredAmount);
        return gatheredAmount;
    }

    //collect salvage from a coordinate
    function collect() external {
        (uint fleetX, uint fleetY) = getFleetLocation(msg.sender);
        require(_placeExists[fleetX][fleetY] == true, 'MAPS: no place');
        places[coordinatePlaces[fleetX][fleetY]].salvage -=
            _gather(msg.sender, places[coordinatePlaces[fleetX][fleetY]].salvage, _miningCooldown / _collectCooldownReduction);
    }
 
    //Fleet can mine mineral depending their fleet's capacity and planet available
    function mine() external {
        (uint fleetX, uint fleetY) = getFleetLocation(msg.sender);
        require(_placeExists[fleetX][fleetY] == true, 'MAPS: no place');
        Place memory miningPlace = places[coordinatePlaces[fleetX][fleetY]];

        //if mining a planet
        if(miningPlace.placeType == PlaceType.PLANET) {
            Planet memory miningPlanet = _planets[miningPlace.childId];
            _planets[miningPlanet.id].availableMineral -=
                _gather(msg.sender, miningPlanet.availableMineral, _miningCooldown);
        }
        //else if mining an asteroid
        else if(miningPlace.placeType == PlaceType.ASTEROID) {
            Asteroid memory miningAsteroid = _asteroids[miningPlace.childId];
            _asteroids[miningAsteroid.id].availableMineral -=
                _gather(msg.sender, miningAsteroid.availableMineral, _miningCooldown / _asteroidCooldownReduction);
        }
        _requestToken();
    }
    
    function refine() external {
        address player = msg.sender;
        require(getPlanetAtFleetLocation(player).hasRefinery == true, "MAP: Fleet not at a refinery");

        uint playerMineral = Fleet.getMineral(player);
        require(playerMineral > 0, "MAP: Player/Fleet has no mineral");
        Fleet.setMineral(player, 0);

        Token.safeTransfer(player, playerMineral);
        _previousBalance -= playerMineral;
        emit MineralRefined(player, playerMineral);
        _requestToken();
    }

    // Returns both x and y coordinates
    function getFleetLocation (address _fleet) public view returns(uint x, uint y) {
        return (fleetLocation[_fleet][0], fleetLocation[_fleet][1]);
    }

    function getFleetsAtLocation(uint _x, uint _y) external view returns(address[] memory) {
        return fleetsAtLocation[_x][_y];
    }

    function getDistanceFromFleet (address _fleet, uint _x, uint _y) public view returns(uint) {
        uint oldX = fleetLocation[_fleet][0];
        uint oldY = fleetLocation[_fleet][1];
        return Helper.getDistance(oldX, oldY, _x, _y);
    }

    function getFleetTravelCost(address _fleet, uint _x, uint _y) public view returns (uint) {
       uint fleetSize = Fleet.getFleetSize(_fleet);
       uint distance = getDistanceFromFleet(_fleet, _x, _y);

       //Every 1000 experience, travel is reduced by 1% up to 50%
       uint travelDiscount = Helper.getMin(50, Fleet.getExperience(_fleet) / 1000);
       return (((distance**2 * _baseTravelCost * fleetSize) * (100-travelDiscount)) / 100) / Treasury.getCostMod();
    }

    function getFleetTravelCooldown(address _fleet, uint _x, uint _y) public view returns (uint) {
       uint distance = getDistanceFromFleet(_fleet, _x, _y);
       return (_baseTravelCooldown + (distance*_travelCooldownPerDistance)) / _timeModifier;
    }

    // ship travel to _x and _y
    function travel(uint _x, uint _y) external {
        require(_placeExists[_x][_y] == true, 'MAPS: place unexplored');
        require(places[coordinatePlaces[_x][_y]].canTravel == true, 'MAPS: no travel');
        address sender = msg.sender;
        require(block.timestamp >= travelCooldown[sender], "MAPS: jump drive recharging");
        require(getDistanceFromFleet(sender, _x, _y) <= _maxTravel, "MAPS: cannot travel that far");
        require(Fleet.getFleetSize(sender) >= _minTravelSize, "MAPS: fleet too small");
        require(Fleet.isInBattle(sender) == false, "MAPS: in battle or takeover");

        uint travelCost = getFleetTravelCost(sender, _x, _y);
        Treasury.pay(sender, travelCost);
        Fleet.addExperience(sender, travelCost);

        travelCooldown[sender] = block.timestamp + getFleetTravelCooldown(sender, _x, _y);

        (uint fleetX, uint fleetY) =  getFleetLocation(sender);
        _setFleetLocation(sender, fleetX, fleetY, _x, _y);
    }

    //player can set recall spot if at a shipyard
    function setRecall() external {
        (uint fleetX, uint fleetY) =  getFleetLocation(msg.sender);
        require(isShipyardLocation(fleetX, fleetY) == true, 'MAP: no shipyard');
        fleetLastShipyardPlace[msg.sender] = coordinatePlaces[fleetX][fleetY];
    }

    //recall player to last shipyard visited
    function recall(bool _goToHaven) external {
        require(Fleet.getFleetSize(msg.sender) < _minTravelSize, "FLEET: too large for recall");

        uint recallX;
        uint recallY;
        if(_goToHaven != true) {
            recallX = places[fleetLastShipyardPlace[msg.sender]].coordX;
            recallY = places[fleetLastShipyardPlace[msg.sender]].coordY;
        }

        (uint fleetX, uint fleetY) =  getFleetLocation(msg.sender);
        _setFleetLocation(msg.sender, fleetX, fleetY, recallX, recallY);
    }

    function setFleetLocation(address _player, uint _xFrom, uint _yFrom, uint _xTo, uint _yTo) external onlyEditor {
        _setFleetLocation(_player, _xFrom, _yFrom, _xTo, _yTo);
    }

    //change fleet location in fleet mapping
    function _setFleetLocation(address _player, uint _xFrom, uint _yFrom, uint _xTo, uint _yTo) internal {
        address[] memory fleetsAtFromLocation = fleetsAtLocation[_xFrom][_yFrom]; //list of fleets at from location
        uint numFleetsAtLocation = fleetsAtFromLocation.length; //number of fleets at from location
        /* this loop goes through fleets at the player's "from" location and when it finds the fleet,
            it removes puts the last element in the array in that fleets place and then removes the last element */
        for(uint i=0;i<numFleetsAtLocation;i++) {
            if(fleetsAtFromLocation[i] == _player) {
                fleetsAtLocation[_xFrom][_yFrom][i] = fleetsAtLocation[_xFrom][_yFrom][numFleetsAtLocation-1]; //assign last element in array to where fleet was
                fleetsAtLocation[_xFrom][_yFrom].pop(); //remove last element in array
            }
        }

        //add fleet to new location fleet list
        fleetsAtLocation[_xTo][_yTo].push(_player);
        fleetLocation[_player][0] = _xTo;
        fleetLocation[_player][1] = _yTo;
    }

    // Setting to 0 disables travel
    function setMaxTravel(uint _new) external onlyOwner {
        _maxTravel = _new;
    }    

    // Setting to 0 removes the secondary cooldown period
    function setTravelTimePerDistance(uint _new) external onlyOwner {
        _travelCooldownPerDistance = _new;
    }

    // setting to 0 removes base travel cooldown
    function setBaseTravelCooldown(uint _new) external onlyOwner {
        _baseTravelCooldown = _new;
    }

    // Functions to setup contract interfaces
    function setShadowPool(address _new) external onlyOwner {
        require(address(0) != _new);
        ShadowPool = IShadowPool(_new);
        emit NewShadowPool(_new);
    }
    function setFleet(address _new) external onlyOwner {
        require(address(0) != _new);
        Fleet = IFleet(_new); 
        emit NewFleet(_new);
    }
    function setToken(address _new) external onlyOwner {
        require(address(0) != _new);
        Token = ShibaBEP20(_new);
        emit NewToken(_new);
    }
    function setTreasury(address _new) external onlyOwner{
        require(address(0) != _new);
        Treasury = ITreasury(_new);
        emit NewTreasury(_new);
    }
    // Maintenance functions
    function setRewardsMod(uint _new) external onlyOwner {
        require(_new <= 100, "MAP: must be <= 100");
        _rewardsMod = _new; // can set to 0 to turn off Token incoming to contract
        emit NewRewardsMod(_new);
    }
    function setRewardsTimer(uint _new) external onlyOwner {
        _rewardsTimer = _new;
    }
    function setRewardsDelay(uint _new) external onlyOwner {
        rewardsDelay = _new;
    }
    function setBaseTravelCost(uint _new) external onlyOwner {
        _baseTravelCost = _new;
    }

    // setting to 0 removes base travel cooldown
    function setTimeModifier(uint _new) external onlyOwner {
        _timeModifier = _new;
    }

    function getTimeModifier() external view returns(uint) {
        return _timeModifier;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IBEP20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/*
 * @dev Implementation of the {IBEP20} interface.
 * This implementation is a copy of @pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol
 * with a burn supply management.
 */
contract ShibaBEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _burnSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function burnSupply() public view returns (uint256) {
        return _burnSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function mint(address _to, uint256 _amount) external virtual onlyOwner{
        _mint(_to, _amount);
    }
    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != BURN_ADDRESS, "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _burnSupply = _burnSupply.add(amount);
        emit Transfer(account, BURN_ADDRESS, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller"s allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import '../interfaces/IBEP20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library Helper {

    function isEqual(string memory _str1, string memory _str2) internal pure returns (bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    function _sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // Create random number <= _mod
    function getRandomNumber(uint _mod, uint _extra) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp + _extra, blockhash(20)))) % _mod;
    }

    function getDistance(uint x1, uint y1, uint x2, uint y2) internal pure returns (uint) {
        uint x = (x1 > x2 ? (x1 - x2) : (x2 - x1));
        uint y = (y1 > y2 ? (y1 - y2) : (y2 - y1));
        return _sqrt(x**2 + y**2);
    }

    //get minimum between 2 numbers
    function getMin(uint num1, uint num2) internal pure returns(uint) {
        if(num1 < num2) {
            return num1;
        }
        else {
            return num2;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
contract Editor is Ownable {

    mapping (address => bool) public editor;
    
        // Addresses that can purchase ships
     modifier onlyEditor {
        require(isEditor(msg.sender));
        _;
    }
    // Is address a editor?
    function isEditor(address _editor) public view returns (bool){
        return editor[_editor] == true ? true : false;
    }
     // Add new editors
    function setEditor(address[] memory _editor) external onlyOwner {
        for (uint i = 0; i < _editor.length; i++) {
        require(editor[_editor[i]] == false, "DRYDOCK: Address is already a editor");
        editor[_editor[i]] = true;
        }
    }
    // Deactivate a editor
    function deactivateEditor ( address _editor) public onlyOwner {
        require(editor[_editor] == true, "DRYDOCK: Address is not a editor");
        editor[_editor] = false;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface ITreasury {

    function pay(address _from, uint _amount) external;
    function deposit(address _from, uint _amount) external;
    function withdraw (address _recipient, uint _amount) external; // onlyDistributor
    function getCostMod() external view returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IShadowPool {
    function replenishPlace(address _jackpot) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Interface for external contracts to interact with the DryDock

interface IFleet {
    function getMineralCapacity(address player) external view returns (uint);
    function getMiningCapacity(address _player) external view returns (uint);
    function getMaxFleetSize(address player) external view returns (uint);
    function getFleetSize(address player) external view returns(uint);
    function isInBattle(address _player) external view returns(bool);
    function getMineral(address _player) external view returns(uint);
    function setMineral(address _player, uint _amount) external;
    function addShipyard(string calldata _name, address _owner, uint _x, uint _y, uint8 _feePercent) external;
    function addExperience(address _player, uint _paid) external;
    function getExperience(address _player) external view returns (uint);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}