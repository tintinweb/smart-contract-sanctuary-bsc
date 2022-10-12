/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract Random {

    uint256 number = 43;

    function next() public returns (uint256) {
        number = (number * 16807) % 2147483647;
        return number;
    }

}
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
interface Result
{
    function SetResult(int256 x, int256 y) external ;
}

contract NumResult is Result
{
    int256 public x;
    int256 public y;
    
    function SetResult(int256 _x, int256 _y) override public{
        x = _x;
        y = _y;
    }



}




struct Task
{
    string Hash;
    uint256 Roles;
    uint256 CurStage;
    mapping(uint256 =>mapping (uint256 => bool)) IsFinished;
    mapping(uint256 =>mapping (uint256 => int256[])) Results;
}


contract Cryten 
{
    mapping(string => Task) public Tasks;
    mapping(string => bool) IsAdded;
    Random random;
    uint256 number = 43;
    address public owner;
    modifier onlyOwner{
        require(msg.sender == owner, "Not called by owner");
        _;
    }
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }
    function GenerateABC() public returns(int256[3][2] memory){
        int256 a = (int256)(next());
        int256 b = (int256)(next());
        int256 c = a * b;

        int256 div1 = (int256)(next());
        int256 div2 = (int256)(next());
        int256 div3 = (int256)(next());

        int256[3] memory data1 = [a * 2 + div1, b * 2 + div2, c * 2 + div3];
        int256[3] memory data2 = [- div1 - a, - b - div2, - c- div3];

        return [data1,data2];


    }
    function CreateTask(int256[][] calldata data, string calldata taskHash) public onlyOwner
    {
        require(!IsAdded[taskHash], "Task already added");
        Task storage task = Tasks[taskHash];
        task.Hash = taskHash;
        task.Roles = 2;
        int256[3][2] memory abc = GenerateABC();
        
        for(uint i = 0;i< 2; i++){
            task.Results[0][i] = data[i];
            for(uint j = 0; j < 3; j++){
                task.Results[0][i].push(abc[i][j]);
            }
        }
        task.CurStage = 1;
        IsAdded[taskHash] = true;
    }
    function GetResults(string calldata taskHash, uint256 stage, uint256 role) public view returns(int256[] memory data){
        return Tasks[taskHash].Results[stage][role];
    }
    function Mul(uint256 role, string calldata taskHash) public
    {
        require(IsAdded[taskHash], "No such task");
        Task storage task = Tasks[taskHash];
        require(task.CurStage > 0, "Not initialze correctly");
        if(task.IsFinished[task.CurStage][role]){
            require(task.IsFinished[task.CurStage][1 - role], "Partner not finished");
            task.CurStage += 1;
        }
        if(task.CurStage == 1){
            int256 e = task.Results[0][role][0] - task.Results[0][role][2];
            int256 f = task.Results[0][role][1] - task.Results[0][role][3];
            task.Results[1][role] = [e,f];
            task.IsFinished[1][role] = true;
            return;
        }
        if(task.CurStage == 2){
            int256 e = task.Results[1][role][0] + task.Results[1][1-role][0];
            int256 f = task.Results[1][role][1] + task.Results[1][1-role][1];
            if(role == 0){
                int256 z = f * task.Results[0][role][2] +
                 e * task.Results[0][role][3] + task.Results[0][role][4];
                task.Results[task.CurStage][role].push(z);
            }
            else{
                int256 z = e * f + f * task.Results[0][role][2] +
                 e * task.Results[0][role][3] + task.Results[0][role][4];
                task.Results[task.CurStage][role].push(z);
            }
            task.IsFinished[task.CurStage][role] = true;
        }
    }

    

    function next() public returns (uint256) {
        number = (number * 16807) % 2147483647;
        return number;
    }
}