/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract hash{
    struct data{
        uint256 id;
        string  pic;
        string  video;
        string  audio;
        string  pdf;
    }
    mapping (uint256=>data) internal Info;
       function exists(uint256 _cnic) internal view returns (bool) {
    uint256 owners = Info[_cnic].id;
    return owners == 0;
  
   }
    function storedata(uint256 _id,string memory _pic,string memory _video,string memory _audio,string memory _pdf) public{
           require (exists(_id),"id is already existed please enter new id");
            Info[_id].id=_id;
            Info[_id].pic=_pic;
            Info[_id].video=_video;
            Info[_id].audio=_audio;
            Info[_id].pdf=_pdf;
        }



     
function getData(uint256 _cnic) public view returns(uint256 ,string memory ,string memory,string memory ,string memory  ){
  return(   Info[_cnic].id ,
            Info[_cnic].pic,
            Info[_cnic].video,
            Info[_cnic].audio,
            Info[_cnic].pdf
  );

}

}