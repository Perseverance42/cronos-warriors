pragma solidity ^0.8.0;

library VisualsLib {
    
    uint256 constant maxNameBytesLenght = 64;
    
    struct Visuals {
        string name;
    }
    
    function isNull(Visuals memory visuals) public pure returns (bool){
        return !isValidName(visuals.name); //might get better check with more attibutes in Visuals
    }
    
    function isValidName(string memory name) public pure returns (bool){
        uint256 l = bytes(name).length;
        return l > 0 && l <= maxNameBytesLenght;
    }
}