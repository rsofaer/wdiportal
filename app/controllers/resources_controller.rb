class ResourcesController < ApplicationController

	def index
		current_user.visits.create(action: "view resources")
		@resources = Resource.all
	end

	def new
		if current_user.role != "coordinator"
			@resource = Resource.new
		else
			flash[:alert] = "You must be a student or instructor"
			current_user.visits.create(action: "UNAUTHORIZED attempt to create resource")
			redirect_to resources_path
		end
	end

	def create
		if current_user.role != "coordinator"
			parameters = params.require(:resource).permit(:title, :url, :description)
			resource = current_user.resources.create(parameters)
			current_user.visits.create(action: "create resource")
			flash[:alert] = "Error: " + resource.errors.full_messages.first if resource.errors.any?
			redirect_to resources_path
		else
			flash[:alert] = "You must be a student or instructor"
			redirect_to resources_path
		end
	end

	def edit
		if current_user.role != "coordinator"
			id = params.require(:id)
			@resource = Resource.find(id)
			if @resource.user != current_user
				flash[:alert] = "That is not your resource!"
				current_user.visits.create(action: "UNAUTHORIZED attempt to edit resource")
				redirect_to :resources
			end
		else
			flash[:alert] = "You must be a student or instructor"
			current_user.visits.create(action: "UNAUTHORIZED attempt to edit resource")
			redirect_to resources_path
		end
	end

	def update
		if current_user.role != "coordinator"
			id = params.require(:id)
			updates = params.require(:resource).permit(:title, :url, :description)
			resource = Resource.find(id)
			if resource.user != current_user
				flash[:alert] = "That is not your resource!"
				redirect_to :resources
			end
			resource.update(updates)
			current_user.visits.create(action: "edit resource")
			flash[:alert] = "Error: " + resource.errors.full_messages.first if resource.errors.any?
			redirect_to resources_path
		else
			flash[:alert] = "You must be a student or instructor"
			current_user.visits.create(action: "UNAUTHORIZED attempt to edit resource")
			redirect_to resources_path
		end
	end

	def destroy
		if current_user.role != "coordinator"
			id = params[:id]
			resource = Resource.find_by_id(id)
			if resource.user != current_user
				flash[:alert] = "That is not your resource!"
				redirect_to :resources
			end
			Resource.destroy(id)
			current_user.visits.create(action: "delete resource")
			redirect_to resources_path
		else
			flash[:alert] = "You must be a student or instructor"
			current_user.visits.create(action: "UNAUTHORIZED attempt to delete resource")
			redirect_to resources_path
		end
	end
end
