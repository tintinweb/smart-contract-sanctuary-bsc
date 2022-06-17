// pragma solidity 0.8.8; //use only solidity version 0.8.8
pragma solidity ^0.8.8; // use  0.8.8 and above

// pragma solidity >=0.8.7 <0.9.0; // all verions from 0.8.7 and less than 0.9.0 not included will work

contract SimpleStorage {
    uint256 favoriteNumber;

    mapping(string => uint256) public nameToFavoriteNUmber;
    struct People {
        uint256 favNumber;
        string name;
    }

    People[] public people;

    function store(uint256 _favNumber) public virtual {
        favoriteNumber = _favNumber;
    }

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favNumber) public {
        //1st approach
        // People memory newPerson = People({
        //     favNumber: _favNumber, name: _name
        // });
        // people.push(newPerson);

        //2nd approach
        people.push(People(_favNumber, _name));
        nameToFavoriteNUmber[_name] = _favNumber;

        // 3rd approach
        // People memory newPerson = People( _favNumber,_name);
        // people.push(newPerson);
    }
}