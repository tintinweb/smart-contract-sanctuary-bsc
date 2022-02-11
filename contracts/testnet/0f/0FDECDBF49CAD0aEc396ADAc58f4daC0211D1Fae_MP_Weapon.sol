// SPDX-License-Identifier: MIT

import "./ERC1155Burnable.sol";

import "./Ownable.sol";

import "./Whitelist.sol";

import "./Strings.sol";

pragma solidity ^0.8.6;

contract MP_Weapon is ERC1155Burnable, Ownable, Whitelist {
    using Strings for uint256;

    struct Weapon_Info{
      string WeaponType;
      string GradeLevel;
      uint256 AttackSpeed;
      uint256 Damage;
      string[] Skill;
    }
    mapping(uint256 => Weapon_Info) private MP_weapons;
    event WeaponInfoAdded(address indexed recipient, uint256 indexed weaponId);

    //probability arrays
    uint16[][2] public PROBs;
    //Skill List
    // string[] SkillList_All;
    string[] SkillList_Melee;
    string[] SkillList_Ranged;

    mapping (uint256 => uint256) private _totalSupply;


    constructor(string memory path) ERC1155(path){
      //Probability for each Individual weapon (Dagger, Musket, Pistol, Scimitar/Sword, Hand Axe)
      PROBs[0] = [0, 50, 5, 20, 5, 20];
      //Probability of getting each level of the equipment (N, R, S, SS)
      PROBs[1] = [0, 50, 46, 3, 1];

      // SkillList_All = [ "Vanguard", "Heroic Strike", "Total Annihilation", "Rending Strike", "Chasseur",
      //               "Elbow Strike", "Roar", "Hide", "Step Back", "Precision shooting",
      //               "Scattering", "Trap", "Bondage Shooting", "Rapid Fire", "Grenade",
      //               "Burn one\'s Boats", "Last one Standing", "Unbeatable", "Run Master", "Poison Master",
      //               "striker", "Skill Master", "Defense Master", "Weapon Master"]
      SkillList_Melee = [ "", "Vanguard", "Heroic Strike", "Total Annihilation", "Rending Strike", "Chasseur",
                    "Elbow Strike", "Roar", "Hide", "Step Back", "Grenade",
                    "Burn one\'s Boats", "Last one Standing", "Unbeatable", "Run Master", "Poison Master",
                    "striker", "Skill Master", "Defense Master", "Weapon Master"];
      SkillList_Ranged = [ "", "Vanguard", "Roar", "Hide", "Step Back", "Precision shooting",
                    "Scattering", "Trap", "Bondage Shooting", "Rapid Fire", "Grenade",
                    "Burn one\'s Boats", "Last one Standing", "Unbeatable", "Run Master", "Poison Master",
                    "striker", "Skill Master", "Defense Master", "Weapon Master"];

    }

    function mintWeapon(address account, uint256 weaponId, uint256 amount, string memory WeaponType, string memory GradeLevel, uint256 AttackSpeed, uint256 Damage, string[] memory Skill) public isWhitelisted returns (uint256){
      _mint(account, weaponId, amount, "");
      MP_weapons[weaponId].WeaponType = WeaponType;
      require(keccak256(bytes(MP_weapons[weaponId].WeaponType)) == keccak256(bytes("")), "WeaponType is null!");
      MP_weapons[weaponId].GradeLevel = GradeLevel;
      require(keccak256(bytes(MP_weapons[weaponId].GradeLevel)) == keccak256(bytes("")), "GradeLevel is null!");
      MP_weapons[weaponId].AttackSpeed = AttackSpeed;
      require(MP_weapons[weaponId].AttackSpeed != 0, "AttackSpeed is 0!");
      MP_weapons[weaponId].Damage = Damage;
      require(MP_weapons[weaponId].Damage != 0, "Damage is 0!");
      
      require(Skill.length != 0, "Skill list is empty!");
      for(uint8 i = 0; i < Skill.length; i ++){
        MP_weapons[weaponId].Skill[i] = Skill[i];
      }          
      return weaponId;
    }


    function mintWeaponRandomly(address account, uint256 weaponId, uint256 amount, uint256 randNum) public isWhitelisted returns (uint256){
      _mint(account, weaponId, amount, "");
        
      require(_exists(weaponId), "ERC1155Supply: set of nonexistent token");
      uint256[] memory ranNums = expand(randNum, 4);

      uint8 typeWeapon = rarityGen(ranNums[0] % 100, 0);
      require(typeWeapon != 0, "typeWeapon is 0!");
      if (typeWeapon == 1) {
        MP_weapons[weaponId].WeaponType = "Dagger";
        MP_weapons[weaponId].AttackSpeed = 0.8 * 10 ** 18;
      }
      else if (typeWeapon == 2) {
        MP_weapons[weaponId].WeaponType = "Musket";
        MP_weapons[weaponId].AttackSpeed = 1.2 * 10 ** 18;
      }
      else if (typeWeapon == 3) {
        MP_weapons[weaponId].WeaponType = "Pistol";
        MP_weapons[weaponId].AttackSpeed = 1.0 * 10 ** 18;
      }
      else if (typeWeapon == 4) {
        MP_weapons[weaponId].WeaponType = "Scimitar";
        MP_weapons[weaponId].AttackSpeed = 1.0 * 10 ** 18;
      }
      else if (typeWeapon == 5) {
        MP_weapons[weaponId].WeaponType = "HandAxe";
        MP_weapons[weaponId].AttackSpeed = 1.2 * 10 ** 18;
      }
      uint8 levelGrade = rarityGen(ranNums[1] % 100, 1);
      require(levelGrade != 0, "levelGrade is 0!");
      if (levelGrade == 1) {
        MP_weapons[weaponId].GradeLevel = "N";
        if(typeWeapon == 1)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 11) + 43) * 10 ** 18;   //43 ~ 53
        if(typeWeapon == 2)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 15) + 65) * 10 ** 18;   //65 ~ 79
        if(typeWeapon == 3)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 13) + 54) * 10 ** 18;   //54 ~ 66
        if(typeWeapon == 4)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 13) + 54) * 10 ** 18;   //54 ~ 66
        if(typeWeapon == 5)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 15) + 65) * 10 ** 18;   //65 ~ 79
        
      }
      else if (levelGrade == 2) {
        MP_weapons[weaponId].GradeLevel = "R";
        if(typeWeapon == 1)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 12) + 52) * 10 ** 18;   //52 ~ 63
        if(typeWeapon == 2)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 18) + 78) * 10 ** 18;   //78 ~ 95
        if(typeWeapon == 3)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 15) + 65) * 10 ** 18;   //65 ~ 79
        if(typeWeapon == 4)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 15) + 65) * 10 ** 18;   //65 ~ 79
        if(typeWeapon == 5)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 18) + 78) * 10 ** 18;   //78 ~ 95
      }
      else if (levelGrade == 3) {
        MP_weapons[weaponId].GradeLevel = "S";
        if(typeWeapon == 1)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 15) + 65) * 10 ** 18;   //65 ~ 79
        if(typeWeapon == 2)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 23) + 97) * 10 ** 18;   //97 ~ 119
        if(typeWeapon == 3)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 19) + 81) * 10 ** 18;   //81 ~ 99
        if(typeWeapon == 4)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 19) + 81) * 10 ** 18;   //81 ~ 99
        if(typeWeapon == 5)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 23) + 97) * 10 ** 18;   //97 ~ 119
      }
      else if (levelGrade == 4) {
        MP_weapons[weaponId].GradeLevel = "SS";
        if(typeWeapon == 1)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 21) + 86) * 10 ** 18;   //86 ~ 106
        if(typeWeapon == 2)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 29) + 130) * 10 ** 18;   //130 ~ 158
        if(typeWeapon == 3)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 25) + 108) * 10 ** 18;   //108 ~ 132
        if(typeWeapon == 4)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 25) + 108) * 10 ** 18;   //108 ~ 132
        if(typeWeapon == 5)
          MP_weapons[weaponId].Damage = ((ranNums[2] % 29) + 130) * 10 ** 18;   //130 ~ 158 
      }

      if(levelGrade == 1 || levelGrade == 2)  { // Grade Level is N or R
        if(typeWeapon == 1 || typeWeapon == 4 || typeWeapon == 5){ // Dagger or Scimitar/Sword or Hand Axe
          uint256[] memory skillIndexs = getSkill(SkillList_Melee, 3, ranNums[3]);
          for(uint8 i = 0; i < 3; i ++){
            MP_weapons[weaponId].Skill[i] = SkillList_Melee[skillIndexs[i]];
          }          
        } else if(typeWeapon == 2 || typeWeapon == 3){ // Musket or Pistol
          uint256[] memory skillIndexs = getSkill(SkillList_Ranged, 3, ranNums[3]);
          for(uint8 i = 0; i < 3; i ++){
            MP_weapons[weaponId].Skill[i] = SkillList_Ranged[skillIndexs[i]];
          }          
        }
      } else if (levelGrade == 3 || levelGrade == 4){ // Grade Level is S or SS
        if(typeWeapon == 1 || typeWeapon == 4 || typeWeapon == 5){ // Dagger or Scimitar/Sword or Hand Axe
          uint256[] memory skillIndexs = getSkill(SkillList_Melee, 4, ranNums[3]);
          for(uint8 i = 0; i < 4; i ++){
            MP_weapons[weaponId].Skill[i] = SkillList_Melee[skillIndexs[i]];
          }          
        } else if(typeWeapon == 2 || typeWeapon == 3){ // Musket or Pistol
          uint256[] memory skillIndexs = getSkill(SkillList_Ranged, 4, ranNums[3]);
          for(uint8 i = 0; i < 4; i ++){
            MP_weapons[weaponId].Skill[i] = SkillList_Ranged[skillIndexs[i]];
          }          
        }
      }


      emit WeaponInfoAdded(account, weaponId);

      return weaponId;
    }

    /*
    * pick amount of skills from skill list
    */
    function getSkill(string[] memory SkillList, uint256 amount, uint256 randomHash) public pure returns (uint256[] memory skillIndexs) {
      uint8 randCount = 0;
      skillIndexs = new uint256[](amount);
      uint256 index = 0;
      uint8 flagDuplicated = 0;
      while(randCount < amount){
        index =  (randomHash % (SkillList.length-1)) + 1;
        flagDuplicated = 0;
        for(uint8 i = 0; i < amount; i ++){
          if(skillIndexs[i] == index){
            flagDuplicated = 1;
            break;
          }
        }
        if (flagDuplicated == 0){
          skillIndexs[randCount++] = index;
        }
          
        randomHash >>= 1;         //can only shift 256times for max
      }      
      return skillIndexs;
    }


    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
      expandedValues = new uint256[](n);
      for (uint256 i = 0; i < n; i++) {
          expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
      }
      return expandedValues;
    }

    /**
     * @dev Converts a digit from 0 - 100 into its corresponding rarity based on the given probability
     * @param _randinput The input from 0 - 100 to use for rarity gen.
     */
    function rarityGen(uint256 _randinput, uint256 number) internal view returns (uint8)
    {
        uint16 currentLowerBound = 0;
        for (uint8 i = 0; i < PROBs[number].length; i++) {
          uint16 thisPercentage = PROBs[number][i];
          if(thisPercentage == 0){
            continue;
          }
          if (
              _randinput >= currentLowerBound &&
              _randinput < currentLowerBound + thisPercentage
          ) return i;
          currentLowerBound = currentLowerBound + thisPercentage;
        }
        return 1;
    }

    /**
     * Get Information of weapon from tokenId
     */
    function getItem(uint256 tokenId) public view returns(Weapon_Info memory) {
      return MP_weapons[tokenId];
    }


    function setProbability(uint256 index, uint16[] calldata array) public onlyOwner{
      PROBs[index] = array;
    }

    function setURI(string memory newURI) public onlyOwner {
      _setURI(newURI);
    }

    function name() external pure returns (string memory) {
        return "MP_Weapon";
    }

    function symbol() external pure returns (string memory) {
        return "MEPGW";
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
      string memory baseURI = ERC1155.uri(tokenId);
      return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
    }

    /*
    * Override burn and burnBatch function to allow for whitelisted addresses to call on these two functions
    */
    function burn(address account, uint256 id, uint256 value) public override isWhitelisted {
      _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override isWhitelisted {
      _burnBatch(account, ids, values);
    }

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates weither any token exist with a given id, or not.
     */
    function _exists(uint256 id) internal view returns(bool) {
        return _totalSupply[id] > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
        override
    {
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            if (from == address(0)) {
                _totalSupply[id] = _totalSupply[id] + amount;
            }
            if (to == address(0)) {
                _totalSupply[id] = _totalSupply[id] - amount;
            }
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}