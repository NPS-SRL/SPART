function [J0, Jm]=Jacob(rxi,r0,rL,P0,pm,i,robot) %#codegen
% Computes the Jacobian of the xi point.
%
% Input ->
%   rxi -> Inertial position of the point of interest.
%   r0 -> Inertial position of the base-spacecraft.
%   r -> Links inertial positions.
%   P0 -> Base-spacecraft twist-propagation vector.
%   pm -> Manipulator twist-propagation vector.
%   i -> Link where the point xi is located.
%   robot -> Robot model.
%
% Output ->
%   J0 -> Base-spacecraft Jacobian
%   Jm -> Manipulator Jacobian

%=== LICENSE ===%

%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU Lesser General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU Lesser General Public License for more details.
% 
%     You should have received a copy of the GNU Lesser General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%=== CODE ===%

%--- Number of links  ---%

%Base Jacobian
J0=[eye(3),zeros(3,3);SkewSym(r0-rxi),eye(3)]*P0;

%Pre-allocate
if not(isempty(coder.target)) %Only use during code generation (allowing symbolic computations)
    Jm=zeros(6,robot.n_q);
end
%Manipulator Jacobian
joints_num=0;
for j=1:i
    %If joint is not fixed
    if robot.joints(j).type~=0
        if robot.con.branch(i,j)==1
            Jm(1:6,robot.joints(j).q_id)=[eye(3),zeros(3,3);SkewSym(rL(1:3,j)-rxi),eye(3)]*pm(1:6,j);
        else
            Jm(1:6,robot.joints(j).q_id)=zeros(6,1);
        end
        joints_num=joints_num+1;
    end
end

%Add zeros if required
if isempty(coder.target) %Only when not pre-allocated
    if joints_num<robot.n_q
        Jm(1:6,joints_num+1:robot.n_q)=zeros(6,robot.n_q-joints_num);
    end
end

end