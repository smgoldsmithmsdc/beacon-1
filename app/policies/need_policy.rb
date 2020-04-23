class NeedPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.assign_role_if_empty
      case @user.role.tag
      when 'manager', 'agent'
        Need.all
      when 'mdt'
        needs_me_or_role 'mdt'
      when 'food_delivery_manager'
        needs_me_role_team'food_delivery_manager'
      when 'service_member'
        needs_me_role_team 'service_member'
      else
        raise "Cannot determine need scope for role #{@user.role.name} #{@user.role.tag}"
      end
    end

    def needs_me_or_role(role_tag)
      Need.includes(:role)
          .where(roles: { tag: role_tag })
          .or(Need.includes(:role).where(user: @user))
    end

    def needs_me_role_team(role_tag)
      Need.includes(:role, user: [:roles])
          .where(roles: { tag: role_tag })
          .or(Need.includes(:role, user: [:roles]).where(user: @user))
          .or(Need.includes(:role, user: [:roles]).where("roles_users.role = '#{role_tag}'"))
    end

  end

  def index?
    @user.in_role_names?(%w(manager agent mdt food_delivery_manager service_member))
  end

  def update?
    @user.in_role_names?(%w(manager agent mdt food_delivery_manager service_member))
  end

  def show?
    @user.in_role_names?(%w(manager agent mdt food_delivery_manager service_member))
  end

  def create?
    admin? || agent? || mdt? || @user.in_role_name?('service_member')
  end
end
